#!/usr/bin/env ruby
# frozen_string_literal: true

module Logging
  module_function

  require "logger"

  # The directory where log files will be stored.
  LOG_DIR = File.expand_path(File.join(__dir__, "..", "log"))

  # The default log level.
  LOG_LEVEL = Logger::DEBUG

  # The maximum size of a log file in bytes.
  LOG_MAX_SIZE = 2_145_728

  # The maximum number of log files to keep.
  LOG_MAX_FILES = 100

  # A hash to store loggers for different classes and methods.
  @loggers = {}

  # Returns the logger for the current class and method.
  #
  # @return [Logger] The logger object.
  def logger
    # Get the name of the current class.
    classname = self.class.name

    # Get the name of the current method.
    methodname = caller(1..1).first[/`([^']*)'/, 1]

    # Get the logger for the current class, or create a new one if it doesn't exist.
    @logger ||= Logging.logger_for(classname, methodname)

    # Set the progname of the logger to include the class and method name.
    @logger.progname = "#{classname}##{methodname}"

    # Return the logger object.
    @logger
  end

  class << self
    # Returns the default log level.
    #
    # @return [Integer] The log level.
    def log_level
      Logger::DEBUG
    end

    # Returns the logger for the specified class and method.
    #
    # @param classname [String] The name of the class.
    # @param methodname [String] The name of the method.
    #
    # @return [Logger] The logger object.
    def logger_for(classname, methodname)
      # Get the logger for the specified class, or create a new one if it doesn't exist.
      @loggers[classname] ||= configure_logger_for(classname, methodname)
    end

    # Configures a logger for the specified class and method.
    #
    # @param _classname [String] The name of the class.
    # @param _methodname [String] The name of the method.
    #
    # @return [Logger] The configured logger object.
    def configure_logger_for(_classname, _methodname)
      # Get the current date in YYYY-MM-DD format.
      current_date = Time.now.strftime("%Y-%m-%d")

      # Construct the log file path.
      log_file = File.join(LOG_DIR, "flowbots-#{current_date}.log")

      # Create a new logger object.
      logger = Logger.new(log_file, LOG_MAX_FILES, LOG_MAX_SIZE)

      # Set the log level.
      logger.level = log_level

      # Return the configured logger object.
      logger
    end
  end
end
