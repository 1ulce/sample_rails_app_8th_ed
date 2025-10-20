#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'optparse'
require 'fileutils'

module AIDX
  class ParseError < StandardError
    def initialize(file, line, key, message)
      super("#{file}:#{line}: #{key} #{message}")
    end
  end

  module Schema
    REQUIRED = {
      a: %w[id summary intent contract io errors sideEffects security perf dependencies example cases],
      t: %w[id covers intent kind]
    }.freeze

    TAG_TYPES = {
      a: {
        'id' => :string,
        'summary' => :string,
        'intent' => :string,
        'contract' => :object,
        'io' => :object,
        'errors' => :array,
        'sideEffects' => :string,
        'security' => :string,
        'perf' => :string,
        'dependencies' => :array,
        'example' => :object,
        'cases' => :array,
        'notes' => :string,
        'invariant' => :string,
        'featureFlag' => :string,
        'telemetry' => :string,
        'ownership' => :string
      }.freeze,
      t: {
        'id' => :string,
        'covers' => :array,
        'intent' => :string,
        'kind' => :string,
        'scenarios' => :array,
        'risk' => :string,
        'flaky' => :boolean,
        'slow' => :boolean,
        'links' => :array,
        'dataset' => :string,
        'seed' => :string,
        'timeout' => :number,
        'owner' => :string
      }.freeze
    }.freeze

    KIND_ENUM = %w[unit integration e2e property mutation].freeze

    def self.required_tags(type)
      REQUIRED.fetch(type) { [] }
    end

    def self.expected_type(type, key)
      TAG_TYPES.fetch(type, {}).fetch(key, :string)
    end

    def self.parse_value(file, line, type, key, raw)
      expected = expected_type(type, key)
      raw = raw.strip
      case expected
      when :string
        if raw.start_with?('"') && raw.end_with?('"')
          JSON.parse(raw)
        else
          raw
        end
      when :array
        value = JSON.parse(raw)
        unless value.is_a?(Array)
          raise ParseError.new(file, line, "@#{type}:#{key}", "expected array JSON")
        end
        value
      when :object
        value = JSON.parse(raw)
        unless value.is_a?(Hash)
          raise ParseError.new(file, line, "@#{type}:#{key}", "expected object JSON")
        end
        value
      when :boolean
        value = JSON.parse(raw)
        unless value == true || value == false
          raise ParseError.new(file, line, "@#{type}:#{key}", "expected boolean JSON")
        end
        value
      when :number
        value = JSON.parse(raw)
        unless value.is_a?(Numeric)
          raise ParseError.new(file, line, "@#{type}:#{key}", "expected numeric JSON")
        end
        value
      else
        JSON.parse(raw)
      end
    rescue JSON::ParserError => e
      raise ParseError.new(file, line, "@#{type}:#{key}", "invalid JSON (#{e.message})")
    end

    def self.validate_block(block)
      errors = []
      missing = required_tags(block.type).reject { |key| block.tags.key?(key) }
      unless missing.empty?
        errors << "#{block.file}:#{block.start_line}: missing required tags #{missing.join(', ')}"
      end
      block.tags.each do |key, data|
        value = data[:value]
        expected = expected_type(block.type, key)
        case expected
        when :array
          unless value.is_a?(Array)
            errors << "#{block.file}:#{data[:line]}: @#{block.type}:#{key} should be an array"
          end
        when :object
          unless value.is_a?(Hash)
            errors << "#{block.file}:#{data[:line]}: @#{block.type}:#{key} should be an object"
          end
        when :boolean
          unless value == true || value == false
            errors << "#{block.file}:#{data[:line]}: @#{block.type}:#{key} should be a boolean"
          end
        when :number
          unless value.is_a?(Numeric)
            errors << "#{block.file}:#{data[:line]}: @#{block.type}:#{key} should be numeric"
          end
        end

        if block.type == :a
          case key
          when 'contract'
            unless value.is_a?(Hash) &&
                   value.key?('requires') && value['requires'].is_a?(Array) &&
                   value.key?('ensures') && value['ensures'].is_a?(Array)
              errors << "#{block.file}:#{data[:line]}: @a:contract must include requires[] and ensures[]"
            end
          when 'example'
            unless value.is_a?(Hash) && value.key?('ok') && value.key?('ng')
              errors << "#{block.file}:#{data[:line]}: @a:example must include ok/ng values"
            end
          when 'cases'
            if value.is_a?(Array) && value.any? { |c| c.to_s.strip.empty? }
              errors << "#{block.file}:#{data[:line]}: @a:cases entries cannot be empty"
            end
          end
        elsif block.type == :t
          case key
          when 'covers'
            if !value.is_a?(Array) || value.empty?
              errors << "#{block.file}:#{data[:line]}: @t:covers must list at least one symbol"
            end
          when 'kind'
            unless KIND_ENUM.include?(value)
              errors << "#{block.file}:#{data[:line]}: @t:kind must be one of #{KIND_ENUM.join(', ')}"
            end
          end
        end
      end

      if block.id.to_s.strip.empty?
        errors << "#{block.file}:#{block.start_line}: missing @#{block.type}:id"
      end

      errors
    end
  end

  class Annotation
    attr_reader :type, :file, :start_line, :tags

    def initialize(type:, file:, start_line:)
      @type = type
      @file = file
      @start_line = start_line
      @tags = {}
    end

    def add_tag(key:, raw:, line:, errors:)
      value = Schema.parse_value(file, line, type, key, raw)
      @tags[key] = { value: value, raw: raw.strip, line: line }
      @start_line = line if key == 'id'
    rescue ParseError => e
      errors << e.message
      @tags[key] = { value: nil, raw: raw.strip, line: line }
    end

    def id
      tag = tags['id']
      tag && tag[:value].to_s
    end
  end

  class Parser
    GLOBS = [
      'app/**/*.{rb,js,ts,jsx,tsx}',
      'lib/**/*.{rb,js,ts,jsx,tsx}',
      'config/**/*.rb',
      'test/**/*.{rb,js,ts,jsx,tsx}'
    ].freeze

    COMMENT_PREFIX = /^\s*(#|\/\/|\*)/
    TAG_REGEX = /@([at]):([A-Za-z][\w]*)\s+(.*)$/

    attr_reader :errors

    def initialize(root: Dir.pwd)
      @root = root
      @errors = []
    end

    def files
      @files ||= begin
        Dir.chdir(@root) do
          GLOBS.flat_map { |pattern| Dir.glob(pattern, File::FNM_EXTGLOB) }
              .uniq
              .select { |path| File.file?(path) }
        end
      end
    end

    def parse
      annotations = []
      files.sort.each do |path|
        annotations.concat(parse_file(path))
      end
      annotations
    end

    private

    def parse_file(path)
      blocks = []
      current = nil
      current_type = nil
      absolute = File.join(@root, path)
      File.open(absolute, 'r:UTF-8') do |file|
        file.each_line.with_index(1) do |line, line_number|
          line = line.chomp
          next unless line.match?(COMMENT_PREFIX)
          match = line.match(TAG_REGEX)
          next unless match

          tag_type = match[1] == 'a' ? :a : :t
          key = match[2]
          raw = match[3]

          if key == 'id'
            blocks << current if current
            current = Annotation.new(type: tag_type, file: path, start_line: line_number)
            current_type = tag_type
          else
            if current.nil?
              @errors << "#{path}:#{line_number}: @#{tag_type}:#{key} appears before @#{tag_type}:id"
              next
            end

            if current_type != tag_type
              blocks << current
              current = Annotation.new(type: tag_type, file: path, start_line: line_number)
              current_type = tag_type
            end
          end

          current.add_tag(key: key, raw: raw, line: line_number, errors: @errors) if current
        end
      end
      blocks << current if current
      blocks
    end
  end

  class Exporter
    def initialize(annotations, root: Dir.pwd)
      @annotations = annotations
      @root = root
    end

    def write
      grouped = @annotations.group_by(&:file)
      count = 0
      grouped.each do |file, blocks|
        next if blocks.empty?
        dest = File.join(@root, 'docs', 'apps', "#{file}.md")
        FileUtils.mkdir_p(File.dirname(dest))
        File.write(dest, render_doc(file, blocks))
        count += 1
      end
      count
    end

    private

    def render_doc(file, blocks)
      code_blocks = blocks.select { |b| b.type == :a }
      test_blocks = blocks.select { |b| b.type == :t }
      lines = []
      lines << "# #{file}"
      unless code_blocks.empty?
        lines << ""
        lines << "## Code Annotations"
        code_blocks.each do |block|
          lines.concat(render_block(block))
        end
      end
      unless test_blocks.empty?
        lines << ""
        lines << "## Test Annotations"
        test_blocks.each do |block|
          lines.concat(render_block(block))
        end
      end
      lines << ""
      lines.join("\n")
    end

    def render_block(block)
      lines = []
      lines << ""
      heading = block.id.to_s.strip.empty? ? "(missing id)" : block.id
      lines << "### #{heading} (line #{block.start_line})"
      block.tags.each do |key, data|
        value = data[:value]
        lines.concat(format_tag(key, value))
      end
      lines
    end

    def format_tag(key, value)
      case value
      when Hash, Array
        [
          "- #{key}:",
          "  ```json",
          *JSON.pretty_generate(value).split("\n").map { |line| "  #{line}" },
          "  ```"
        ]
      when nil
        ["- #{key}: (invalid or missing value)"]
      else
        ["- #{key}: #{value}"]
      end
    end
  end

  class Runner
    attr_reader :annotations

    def initialize(root: Dir.pwd)
      @root = root
    end

    def parse
      return if @annotations
      parser = Parser.new(root: @root)
      @annotations = parser.parse
      @parse_errors = parser.errors
    end

    def validate
      parse
      errors = []
      errors.concat(@parse_errors)
      @annotations.each do |block|
        errors.concat(Schema.validate_block(block))
      end
      errors
    end

    def export
      parse
      Exporter.new(@annotations, root: @root).write
    end
  end

  class CLI
    def self.run(argv, root: Dir.pwd)
      command = argv.shift || 'validate'
      runner = Runner.new(root: root)

      case command
      when 'validate'
        errors = runner.validate
        if errors.empty?
          puts 'aidx: validation passed'
        else
          errors.each { |err| warn err }
          exit 1
        end
      when 'export'
        errors = runner.validate
        unless errors.empty?
          errors.each { |err| warn err }
          warn 'aidx: export aborted due to validation errors'
          exit 1
        end
        count = runner.export
        puts "aidx: exported #{count} files"
      else
        warn "Unknown command '#{command}'. Use 'validate' or 'export'."
        exit 1
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  AIDX::CLI.run(ARGV, root: Dir.pwd)
end
