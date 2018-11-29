# encoding: UTF-8

######################################################################
#
# Based on example code written by Tiago Lopo
#
# from https://stackoverflow.com/questions/9433924/46817584#46817584
#
#######################################################################

require 'singleton'

class MultiIO < File
  include Singleton 
  @@path = 'out.log'
  @@targets = []
  @@mutex = Mutex.new

  def self.instance(path)
    @@path = path unless path.nil?
    self.open(@@path,'w+')
  end

  def puts(str)
    write "#{str}"
  end

  def write(str)
    @@mutex.synchronize do 
      @@targets.each { |t| t.write str; flush }
    end
  end

  def setTargets(targets)
    raise 'setTargets is a one-off operation' unless @@targets.length < 1
    targets.each do |t|
       @@targets.push STDOUT.clone if t == STDOUT 
       @@targets.push STDERR.clone if t == STDERR
       break if t == STDOUT or t == STDERR  
    end
    @@targets.push(File.open(@@path,'w+'))
    self
  end

  def close
    @@targets.each {|t| t.close}
  end
end
