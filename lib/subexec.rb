# # Subexec
# * by Peter Kieltyka
# * http://github/nulayer/subexec
#
# ## Description
#
# Subexec is a simple library that spawns an external command with
# an optional timeout parameter. It relies on Ruby 1.9's Process.spawn
# method. Also, it works with synchronous and asynchronous code.
#
# Useful for libraries that are Ruby wrappers for CLI's. For example,
# resizing images with ImageMagick's mogrify command sometimes stalls
# and never returns control back to the original process. Subexec
# executes mogrify and preempts if it gets lost.
#
# ## Usage
#
# # Print hello
# sub = Subexec.run "echo 'hello' && sleep 3", :timeout => 5
# puts sub.output     # returns: hello
# puts sub.exitstatus # returns: 0
#
# # Timeout process after a second
# sub = Subexec.run "echo 'hello' && sleep 3", :timeout => 1
# puts sub.output     # returns:
# puts sub.exitstatus # returns:

require 'subexec/version'

class Subexec

  attr_accessor :pid,
                :command,
                :lang,
                :output,
                :exitstatus,
                :timeout,
                :log_file

  def self.run(command, options={})
    sub = new(command, options)
    sub.run!
    sub
  end

  def initialize(command, options={})
    self.command    = command
    self.lang       = options[:lang]      || "C"
    self.timeout    = options[:timeout]   || -1     # default is to never timeout
    self.log_file   = options[:log_file]
    self.exitstatus = 0
  end

  def run!
    exec
  end

  private

  def exec
    if !(RUBY_PLATFORM =~ /win32|mswin|mingw/).nil?
      self.output = `set LANG=#{lang} && #{command} 2>&1`
    else
      self.output = `LANG=#{lang} && export $LANG && #{command} 2>&1`
    end
    self.exitstatus = $?.exitstatus
  end

end
