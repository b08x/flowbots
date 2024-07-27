#!/usr/bin/env ruby
# frozen_string_literal: true

module MarkdownYaml
  include Treetop::Runtime

  def root
    @root ||= :document
  end

  module Document0
    def markdown_content
      elements[1]
    end
  end

  def _nt_document
    start_index = index
    if node_cache[:document].has_key?(index)
      cached = node_cache[:document][index]
      if cached
        node_cache[:document][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r2 = _nt_yaml_front_matter
    if r2
      r1 = r2
    else
      r1 = instantiate_node(SyntaxNode,input, index...index)
    end
    s0 << r1
    if r1
      r3 = _nt_markdown_content
      s0 << r3
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Document0)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:document][start_index] = r0

    r0
  end

  module YamlFrontMatter0
    def newline1
      elements[1]
    end

    def newline2
      elements[4]
    end
  end

  def _nt_yaml_front_matter
    start_index = index
    if node_cache[:yaml_front_matter].has_key?(index)
      cached = node_cache[:yaml_front_matter][index]
      if cached
        node_cache[:yaml_front_matter][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if (match_len = has_terminal?('---', false, index))
      r1 = instantiate_node(SyntaxNode,input, index...(index + match_len))
      @index += match_len
    else
      terminal_parse_failure('\'---\'')
      r1 = nil
    end
    s0 << r1
    if r1
      r2 = _nt_newline
      s0 << r2
      if r2
        s3, i3 = [], index
        loop do
          r4 = _nt_filtered_yaml_content
          if r4
            s3 << r4
          else
            break
          end
        end
        r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
        s0 << r3
        if r3
          if (match_len = has_terminal?('---', false, index))
            r5 = instantiate_node(SyntaxNode,input, index...(index + match_len))
            @index += match_len
          else
            terminal_parse_failure('\'---\'')
            r5 = nil
          end
          s0 << r5
          if r5
            r6 = _nt_newline
            s0 << r6
          end
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(YamlFrontMatter0)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:yaml_front_matter][start_index] = r0

    r0
  end

  module FilteredYamlContent0
    def yaml_line
      elements[1]
    end
  end

  def _nt_filtered_yaml_content
    start_index = index
    if node_cache[:filtered_yaml_content].has_key?(index)
      cached = node_cache[:filtered_yaml_content][index]
      if cached
        node_cache[:filtered_yaml_content][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    i1 = index
    i2 = index
    if (match_len = has_terminal?('---', false, index))
      r3 = instantiate_node(SyntaxNode,input, index...(index + match_len))
      @index += match_len
    else
      terminal_parse_failure('\'---\'')
      r3 = nil
    end
    if r3
      r3 = SyntaxNode.new(input, (index-1)...index) if r3 == true
      r2 = r3
    else
      r4 = _nt_date_line
      if r4
        r4 = SyntaxNode.new(input, (index-1)...index) if r4 == true
        r2 = r4
      else
        r5 = _nt_layout_line
        if r5
          r5 = SyntaxNode.new(input, (index-1)...index) if r5 == true
          r2 = r5
        else
          @index = i2
          r2 = nil
        end
      end
    end
    if r2
      @index = i1
      r1 = nil
      terminal_parse_failure("(any alternative)", true)
    else
      @terminal_failures.pop
      @index = i1
      r1 = instantiate_node(SyntaxNode,input, index...index)
    end
    s0 << r1
    if r1
      r6 = _nt_yaml_line
      s0 << r6
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(FilteredYamlContent0)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:filtered_yaml_content][start_index] = r0

    r0
  end

  module YamlLine0
  end

  module YamlLine1
    def newline
      elements[1]
    end
  end

  def _nt_yaml_line
    start_index = index
    if node_cache[:yaml_line].has_key?(index)
      cached = node_cache[:yaml_line][index]
      if cached
        node_cache[:yaml_line][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    s1, i1 = [], index
    loop do
      i2, s2 = index, []
      i3 = index
      r4 = _nt_newline
      if r4
        @index = i3
        r3 = nil
      else
        @index = i3
        r3 = instantiate_node(SyntaxNode,input, index...index)
      end
      s2 << r3
      if r3
        if index < input_length
          r5 = true
          @index += 1
        else
          terminal_parse_failure("any character")
          r5 = nil
        end
        s2 << r5
      end
      if s2.last
        r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
        r2.extend(YamlLine0)
      else
        @index = i2
        r2 = nil
      end
      if r2
        s1 << r2
      else
        break
      end
    end
    if s1.empty?
      @index = i1
      r1 = nil
    else
      r1 = instantiate_node(SyntaxNode,input, i1...index, s1)
    end
    s0 << r1
    if r1
      r6 = _nt_newline
      s0 << r6
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(YamlLine1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:yaml_line][start_index] = r0

    r0
  end

  module DateLine0
  end

  module DateLine1
    def newline
      elements[2]
    end
  end

  def _nt_date_line
    start_index = index
    if node_cache[:date_line].has_key?(index)
      cached = node_cache[:date_line][index]
      if cached
        node_cache[:date_line][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if (match_len = has_terminal?('date:', false, index))
      r1 = instantiate_node(SyntaxNode,input, index...(index + match_len))
      @index += match_len
    else
      terminal_parse_failure('\'date:\'')
      r1 = nil
    end
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        i3, s3 = index, []
        i4 = index
        r5 = _nt_newline
        if r5
          @index = i4
          r4 = nil
        else
          @index = i4
          r4 = instantiate_node(SyntaxNode,input, index...index)
        end
        s3 << r4
        if r4
          if index < input_length
            r6 = true
            @index += 1
          else
            terminal_parse_failure("any character")
            r6 = nil
          end
          s3 << r6
        end
        if s3.last
          r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
          r3.extend(DateLine0)
        else
          @index = i3
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
      s0 << r2
      if r2
        r7 = _nt_newline
        s0 << r7
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(DateLine1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:date_line][start_index] = r0

    r0
  end

  module LayoutLine0
  end

  module LayoutLine1
    def newline
      elements[2]
    end
  end

  def _nt_layout_line
    start_index = index
    if node_cache[:layout_line].has_key?(index)
      cached = node_cache[:layout_line][index]
      if cached
        node_cache[:layout_line][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if (match_len = has_terminal?('layout:', false, index))
      r1 = instantiate_node(SyntaxNode,input, index...(index + match_len))
      @index += match_len
    else
      terminal_parse_failure('\'layout:\'')
      r1 = nil
    end
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        i3, s3 = index, []
        i4 = index
        r5 = _nt_newline
        if r5
          @index = i4
          r4 = nil
        else
          @index = i4
          r4 = instantiate_node(SyntaxNode,input, index...index)
        end
        s3 << r4
        if r4
          if index < input_length
            r6 = true
            @index += 1
          else
            terminal_parse_failure("any character")
            r6 = nil
          end
          s3 << r6
        end
        if s3.last
          r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
          r3.extend(LayoutLine0)
        else
          @index = i3
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
      s0 << r2
      if r2
        r7 = _nt_newline
        s0 << r7
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(LayoutLine1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:layout_line][start_index] = r0

    r0
  end

  module MarkdownContent0
  end

  def _nt_markdown_content
    start_index = index
    if node_cache[:markdown_content].has_key?(index)
      cached = node_cache[:markdown_content][index]
      if cached
        node_cache[:markdown_content][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    s0, i0 = [], index
    loop do
      i1, s1 = index, []
      i2 = index
      r3 = _nt_end_of_file
      if r3
        @index = i2
        r2 = nil
      else
        @index = i2
        r2 = instantiate_node(SyntaxNode,input, index...index)
      end
      s1 << r2
      if r2
        if index < input_length
          r4 = true
          @index += 1
        else
          terminal_parse_failure("any character")
          r4 = nil
        end
        s1 << r4
      end
      if s1.last
        r1 = instantiate_node(SyntaxNode,input, i1...index, s1)
        r1.extend(MarkdownContent0)
      else
        @index = i1
        r1 = nil
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    r0 = instantiate_node(SyntaxNode,input, i0...index, s0)

    node_cache[:markdown_content][start_index] = r0

    r0
  end

  def _nt_newline
    start_index = index
    if node_cache[:newline].has_key?(index)
      cached = node_cache[:newline][index]
      if cached
        node_cache[:newline][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0 = index
    if (match_len = has_terminal?('\r\n', false, index))
      r1 = instantiate_node(SyntaxNode,input, index...(index + match_len))
      @index += match_len
    else
      terminal_parse_failure('\'\\r\\n\'')
      r1 = nil
    end
    if r1
      r1 = SyntaxNode.new(input, (index-1)...index) if r1 == true
      r0 = r1
    else
      if (match_len = has_terminal?('\n', false, index))
        r2 = instantiate_node(SyntaxNode,input, index...(index + match_len))
        @index += match_len
      else
        terminal_parse_failure('\'\\n\'')
        r2 = nil
      end
      if r2
        r2 = SyntaxNode.new(input, (index-1)...index) if r2 == true
        r0 = r2
      else
        if (match_len = has_terminal?('\r', false, index))
          r3 = instantiate_node(SyntaxNode,input, index...(index + match_len))
          @index += match_len
        else
          terminal_parse_failure('\'\\r\'')
          r3 = nil
        end
        if r3
          r3 = SyntaxNode.new(input, (index-1)...index) if r3 == true
          r0 = r3
        else
          @index = i0
          r0 = nil
        end
      end
    end

    node_cache[:newline][start_index] = r0

    r0
  end

  def _nt_end_of_file
    start_index = index
    if node_cache[:end_of_file].has_key?(index)
      cached = node_cache[:end_of_file][index]
      if cached
        node_cache[:end_of_file][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0 = index
    if index < input_length
      r1 = true
      @index += 1
    else
      terminal_parse_failure("any character")
      r1 = nil
    end
    if r1
      @index = i0
      r0 = nil
      terminal_parse_failure("any character", true)
    else
      @terminal_failures.pop
      @index = i0
      r0 = instantiate_node(SyntaxNode,input, index...index)
    end

    node_cache[:end_of_file][start_index] = r0

    r0
  end

end

class MarkdownYamlParser < Treetop::Runtime::CompiledParser
  include MarkdownYaml
end
