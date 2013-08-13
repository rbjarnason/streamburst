class MediaFormatException < StandardError
end

class Shell
  def initialize(logger)
    @logger = logger
  end

  def execute(command)
    @logger.info("Execute: #{command}")
    IO.popen(command) do |pipe|
      pipe.each("\r") do |line|
        @logger.debug(line)
        $defout.flush
      end
    end
    raise MediaFormatException if $?.exitstatus != 0
  end
end
