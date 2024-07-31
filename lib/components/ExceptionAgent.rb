#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'

require_relative 'WorkflowAgent'

module Flowbots
  class ExceptionAgent < WorkflowAgent
    def initialize
      logger.debug "Initializing ExceptionAgent"
      begin
        cartridge_path = File.join(CARTRIDGE_DIR, "@b08x", "cartridges", "exception_handler.yml")
        logger.debug "Cartridge path: #{cartridge_path}"

        super("exception_handler", cartridge_path)
        logger.debug "SuperClass initialized"

        @file_structure = load_file_structure
        logger.debug "File structure loaded"

        logger.info "ExceptionAgent initialized successfully"
      rescue StandardError => e
        logger.error "Error initializing ExceptionAgent: #{e.message}"
        logger.error e.backtrace.join("\n")
        raise # Re-raise the exception after logging
      end
    end

    def process_exception(classname, exception)
      logger.debug "Processing exception for class: #{classname}"
      exception_details = {
        classname: classname,
        message: exception.message,
        backtrace: exception.backtrace&.join("\n")
      }

      relevant_files = extract_relevant_files(exception)
      exception_details[:relevant_files] = relevant_files

      prompt = generate_exception_prompt(exception_details)

      begin
        logger.debug "Sending prompt to agent"
        response = process(prompt)
        logger.debug "Received response from agent"
        report = format_exception_report(response, exception_details)
        write_markdown_report(report, exception_details)
        WorkflowOrchestrator.cleanup
        report
      rescue StandardError => e
        logger.error("Exception in ExceptionAgent#process_exception: #{e.message}")
        logger.error e.backtrace.join("\n")
        fallback_report = fallback_exception_report(exception_details)
        write_markdown_report(fallback_report, exception_details)
        WorkflowOrchestrator.cleanup
        fallback_report
      end
    end

    private

    def load_file_structure
      file_path = File.expand_path('../../../flowbots.json', __FILE__)
      logger.debug "Loading file structure from: #{file_path}"
      JSON.parse(File.read(file_path))
    rescue StandardError => e
      logger.error "Error loading file structure: #{e.message}"
      {}
    end

    def extract_relevant_files(exception)
      logger.debug "Extracting relevant files for exception"
      relevant_files = {}
      exception.backtrace.each do |trace_line|
        file_path = trace_line.split(':').first
        file_name = File.basename(file_path)
        file_info = @file_structure['files'].find { |f| f['filename'] == file_name }
        if file_info && !relevant_files.key?(file_name)
          relevant_files[file_name] = file_info['content']
        end
      end
      logger.debug "Extracted #{relevant_files.keys.size} relevant files"
      relevant_files
    end

    def generate_exception_prompt(exception_details)
      logger.debug "Generating exception prompt"

      <<~PROMPT
        Oh my stars!! Something terrible has happened!:

        Class: #{exception_details[:classname]}
        Message: #{exception_details[:message]}

        Backtrace:
        #{exception_details[:backtrace]}

        Relevant Files:
        #{exception_details[:relevant_files].map { |name, content| "#{name}:\n#{content}\n" }.join("\n")}

        Could you whip up a report that's easy for our team to understand but still includes all the important technical details? Thanks a bunch!
      PROMPT
    end

    def format_exception_report(agent_response, exception_details)
      logger.debug "Formatting exception report"

      <<~REPORT
        # 🤖 FlowBot Exception Report 🤖

        #{agent_response}

        ## Exception Details

        - **Class:** #{exception_details[:classname]}
        - **Message:** #{exception_details[:message]}

        ### Backtrace

        ```
        #{exception_details[:backtrace]}
        ```

        If you need more information, please check the logs or contact the development team.
      REPORT
    end

    def fallback_exception_report(exception_details)
      logger.debug "Generating fallback exception report"

      <<~REPORT
        # 🚨 FlowBot Exception Report (Fallback) 🚨

        Oops! We encountered an exception, and we're having trouble generating a detailed report right now. Here's what we know:

        ## Exception Details

        - **Class:** #{exception_details[:classname]}
        - **Message:** #{exception_details[:message]}

        ### Backtrace

        ```
        #{exception_details[:backtrace]}
        ```

        We're working on resolving this issue. In the meantime, you might want to:

        1. Check your internet connection
        2. Verify that all required services are running
        3. Try your request again in a few minutes

        If the problem persists, please contact the development team with the above information.

        We apologize for any inconvenience!
      REPORT
    end

    def write_markdown_report(report, exception_details)
      logger.debug "Writing markdown report"
      
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      filename = "exception_report_#{timestamp}.md"
      dir_path = File.expand_path('../../../exception_reports', __FILE__)
      FileUtils.mkdir_p(dir_path)
      file_path = File.join(dir_path, filename)

      File.write(file_path, report)
      logger.info("Exception report written to: #{file_path}")
    end
  end
end
