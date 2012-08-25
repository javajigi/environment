require 'erb'

module Platform
    def self.get(klass)
        windowsName = "Windows" + klass.name
        unixName = "Unix" + klass.name
        if windows? and Object::const_defined?(windowsName)
            return Object::const_get(windowsName)
        elsif Object::const_defined?(unixName)
            return Object::const_get(unixName)
        else
            return klass
        end
    end
    def self.windows?
        return RUBY_PLATFORM =~ /win32/i 
    end
end

class Subversion
    def execute(*args)
        system "svn", *args
    end
end

def pid_by_name(name)
    pid = `ps -ef | grep \"#{name}/\" | grep -v \"grep\" | awk '{print \$2}' | sed '2,\$d'`.strip
    if pid.length == 0 then
        pid = nil
    else
        pid = pid.to_i
    end
    puts "pid is #{pid}"
    return pid
end

def process_templates(pattern, binding)
    pattern = pattern.tr("\\", File::SEPARATOR)
    puts "Scan #{pattern}"
    Dir.glob(pattern) { |filename|
        puts "Found a template #{filename}"
        template = File.open(filename, "r") do |f|
            ERB.new(f.read())
        end
        File.open(File.join(File.dirname(filename), File.basename(filename, ".erb")), "w") do |f|
            f.write(template.result(binding))
        end
    }
end

module AppController
    def install
        raise NotImplementedError.new
    end
    def uninstall
        raise NotImplementedError.new
    end
    def start
        raise NotImplementedError.new
    end
    def stop 
        raise NotImplementedError.new
    end
    def update(revision)
        raise NotImplementedError.new
    end
    def build
        raise NotImplementedError.new
    end
    def log_tail
        raise NotImplementedError.new
    end
    def log_edit
        raise NotImplementedError.new
    end

    def download_package(src, dest)
        @svn.execute '--username', 'BDS_INSTALLER', '--password', 'nhn135!#%', 'export', src, dest
    end
end

class HttpdController
    include AppController
    
    def initialize(config, app)
        @config = config
        @binary_scm = app['binary_scm']
        @config_scm = app['config_scm']
        @httpd_home = app['httpd_home']
        @name = app['name']
        @svn = Platform.get(Subversion).new
    end
    def install
        download_package @binary_scm, @httpd_home
        update(nil)
        register
    end
    def uninstall
        unregister
        rm_rf @httpd_home
    end
    def update(revision)
        @svn.execute "--force", "export", @config_scm, @httpd_home
        process_templates File.join(@httpd_home, "**", "*.erb"), binding
    end
end

class WindowsHttpdController < HttpdController
    def register
        system "#{@httpd_home}/bin/httpd.exe -k install -n \"#{@name}\""
    end
    def unregister
        system "#{@httpd_home}/bin/httpd.exe -k uninstall -n \"#{@name}\""
    end
    def start
        system "#{@httpd_home}/bin/httpd.exe -k start -n \"#{@name}\""
    end
    def stop
        system "#{@httpd_home}/bin/httpd.exe -k stop -n \"#{@name}\""
    end
end

class UnixHttpdController < HttpdController
    def register
        #rc.d?
    end
    def unregister
    end
    def start
        system "#{@httpd_home}/bin/apachectl start"
    end
    def stop
        system "#{@httpd_home}/bin/apachectl stop"
        sleep 0.5
    end
end

class TomcatController
    include AppController
    
    def initialize(config, app)
        @config = config
        @binary_scm = app['binary_scm']
        @config_scm = app['config_scm']
        @catalina_home = app['catalina_home']
        @svn = Platform.get(Subversion).new
    end
    def install
        download_package @binary_scm, @catalina_home
        update(nil)
    end
    def uninstall
        rm_rf @catalina_home
    end
    def update(revision)
        @svn.execute "--force", "export", @config_scm, @catalina_home
        process_templates File.join(@catalina_home, "**", "*.erb"), binding
    end
end

class MemcachedController
    include AppController
    
    def initialize(config, app)
        @config = config
        @binary_scm = app['binary_scm']
        @memcached_home = app['memcached_home']
        @svn = Platform.get(Subversion).new
    end
    def install
        download_package @binary_scm, @memcached_home
        register
    end
    def register
        system "#{@memcached_home}/memcached.exe -d install"
    end
    def uninstall
        unregister
        rm_rf @memcached_home
    end
    def unregister
        system "#{@memcached_home}/memcached.exe -d uninstall"
    end
    def start
        system "#{@memcached_home}/memcached.exe -d start"
    end
    def stop
        system "#{@memcached_home}/memcached.exe -d stop"
    end
end

class WebAppController
    include AppController
    
    def initialize(config, app)
        @config = config
        @scm = app['scm']
        @src_dir = app['src_dir']
        @build = app['build']
        @catalina_base = app['catalina_base']
        @catalina_home = app['catalina_home']
        @java_opts = app['java_opts']
        @ci_rss = app['ci_rss']
        @svn = Platform.get(Subversion).new
        ENV['CATALINA_HOME'] = @catalina_home
        ENV['CATALINA_BASE'] = @catalina_base
        ENV['JAVA_OPTS'] = @java_opts
    end
    def install
        @svn.execute "checkout", @scm, @src_dir
    end
    def uninstall
        rm_rf @src_dir
    end
    def update(revision)
        if revision then
            @svn.execute "checkout", "-r#{revision}", @scm, @src_dir
        else
            @svn.execute "checkout", @scm, @src_dir
        end
    end
    def build
        #system "cd #{@src_dir} && #{@build}"
        sh "cd #{@src_dir} && #{@build}"
    end
    def rsync
	puts @rsync
        sh "#{@rsync}"
    end
    def log_tail
        system "tail -n 50 -f #{@catalina_base}/logs/catalina.out"
    end
    def log_edit
        system "vi #{@catalina_base}/logs/catalina.out"
    end
    def autodeploy
        require 'logger'
        logger = Logger.new(STDOUT)
        last_deployed = [0, 0]
        while (true) do
            successful = last_successful_build(@ci_rss)
            logger.debug("Last successful build is r#{successful[0]}")
            if (successful[0] > last_deployed[0]) then
                logger.info("Deploy r#{successful[0]}")
                update(successful[0])
                build
                stop
                start
                last_deployed = successful
            else
                logger.debug("No changes")
            end
            sleep 10
        end
    end
    def last_successful_build(rss_url)
        require 'open-uri'
        require "rexml/document"
        content = "" # raw content of rss feed will be loaded here
        open(rss_url) do |s| content = s.read end
        
        rss = REXML::Document.new content
        rss.elements["/feed//entry[1]/title"].each {
            |title|
            m = /#(\d+)\.(\d+) was successful/.match(title.value)
            revision = m[1].to_i
            build = m[2].to_i
            return [revision, build]
        }
        return nil
    end
end

class WindowsWebAppController < WebAppController
    def start
        system "#{@catalina_home}/bin/startup.bat"
    end
    def stop 
        system "#{@catalina_home}/bin/shutdown.bat"
    end
end

class UnixWebAppController < WebAppController
    def start
        system "#{@catalina_home}/bin/startup.sh"
    end
    def stop 
        system "#{@catalina_home}/bin/shutdown.sh"
        puts "Wait until die"
        trial = 0
        max_trial = 10
        while trial < max_trial
            puts "#{max_trial - trial} seconds remained"
            break unless pid_by_name(@catalina_base)
            trial = trial + 1
            sleep 1
        end
        if trial == max_trial then
            Process.kill "KILL", pid_by_name(@catalina_base)
        end
    end
end

class BatchController
    include AppController

    def initialize(config, app)
        @config = config
        @svn = Platform.get(Subversion).new
        @scm = app['scm']
        @src_dir = app['src_dir']
		@build = app['build']
		@executable_jar_path = app['executable_jar_path']
    end

    def update(revision)
        if revision then
            @svn.execute "checkout", "-r#{revision}", @scm, @src_dir
        else
            @svn.execute "checkout", @scm, @src_dir
        end
    end

    def build
        sh "cd #{@src_dir} && #{@build}"
    end

	def start
		kill_batch_process
		sh "java -jar #{@executable_jar_path} &"
	end

	def stop
		kill_batch_process
	end

	def kill_batch_process
        batch_process = `ps -ef | grep [a]a-batch`
        if !batch_process.empty?
            batch_process =~ /\w+ +(\d+) +\d+/
            batch_pid = $1
            `kill -9 #{batch_pid}`
        end
	end
end
