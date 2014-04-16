module MysqlSlaver
  class CLI < ::Thor
    option :master_host,           :required => true, :desc => "The server which will be the replication master, for this slave"
    option :database,              :required => true, :desc => "The database to copy from the master"
    option :replication_user,      :required => true, :desc => "DB user (on the master host), with replication permissions"
    option :replication_password,  :required => true, :desc => "DB password for the replication user"
    option :root_password,         :desc     => "Password for the mysql root user (on both master and slave)"
    desc "enslave", "start mysql replication to this host from a master"
    long_desc <<-LONGDESC
    LONGDESC
    def enslave
      MysqlSlaver::Slaver.new(
          :master_host          => options[:master_host],
          :mysql_root_password  => options[:root_password],
          :database             => options[:database],
          :replication_user     => options[:replication_user],
          :replication_password => options[:replication_password]
      ).enslave!
    end
  end
end