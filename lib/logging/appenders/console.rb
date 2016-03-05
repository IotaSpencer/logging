
module Logging::Appenders

  # This class is provides an Appender base class for writing to the standard IO
  # stream - STDOUT and STDERR. This class should not be instantiated directly.
  # The `Stdout` and `Stderr` subclasses should be used.
  class Console < ::Logging::Appenders::IO

    # call-seq:
    #    Stdout.new( name = 'stdout' )
    #    Stderr.new( :layout => layout )
    #    Stdout.new( name = 'stdout', :level => 'info' )
    #
    # Creates a new Stdout/Stderr Appender. The name 'stdout'/'stderr' will be
    # used unless another is given. Optionally, a layout can be given for the
    # appender to use (otherwise a basic appender will be created) and a log
    # level can be specified.
    #
    # Options:
    #
    #    :layout => the layout to use when formatting log events
    #    :level  => the level at which to log
    #
    def initialize( *args )
      name = self.class.name.split("::").last.downcase
      io   = Object.const_get(name.upcase)

      opts = Hash === args.last ? args.pop : {}
      name = args.shift unless args.empty?

      opts[:encoding] = io.external_encoding if io.respond_to? :external_encoding

      super(name, io, opts)
    rescue NameError
      raise RuntimeError, "Please do not use the `Logging::Appenders::Console` class directly - " +
                          "use `Logging::Appenders::Stdout` and `Logging::Appenders::Stderr` instead"
    end

  private

    # @override of ::Logging::Appenders::IO
    def canonical_write( str )
      return self if @io.nil?
      str = str.force_encoding(encoding) if encoding && str.encoding != encoding
      @io.write str # instead of syswrite
      self
    rescue StandardError => err
      handle_internal_error(err)
    end
  end

  # This class provides an Appender that can write to STDOUT.
  Stdout = Class.new(Console)

  # This class provides an Appender that can write to STDERR.
  Stderr = Class.new(Console)

  # Accessor / Factory for the Stdout appender.
  #
  def self.stdout( *args )
    if args.empty?
      return self['stdout'] || ::Logging::Appenders::Stdout.new
    end
    ::Logging::Appenders::Stdout.new(*args)
  end

  # Accessor / Factory for the Stderr appender.
  #
  def self.stderr( *args )
    if args.empty?
      return self['stderr'] || ::Logging::Appenders::Stderr.new
    end
    ::Logging::Appenders::Stderr.new(*args)
  end
end
