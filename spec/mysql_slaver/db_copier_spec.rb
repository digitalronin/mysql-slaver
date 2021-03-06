require 'spec/spec_helper'

module MysqlSlaver
  describe DbCopier do
    let(:executor) { double(Executor, :execute => true, :ssh_command => "dummy-ssh-command") }

    let(:params) {
      {
        :master_host         => 'my.db.host',
        :mysql_root_password => 'supersekrit',
        :database            => 'myappdb',
        :executor            => executor
      }
    }
    subject(:copier) { described_class.new(params) }

    describe "#copy!" do
      it "stops slave" do
        copier.copy!
        stop = %[mysql  -u root -p supersekrit -e "stop slave"]
        expect(executor).to have_received(:execute).with(stop)
      end

      it "loads data" do
        dump_and_load = "dummy-ssh-command | mysql  -u root -p supersekrit myappdb"
        expect(executor).to receive(:execute).once.ordered.with(dump_and_load)
        copier.copy!
      end

      context "dumping" do
        it "issues mysqldump over ssh" do
          dump = "mysqldump  -u root -p supersekrit -h my.db.host --master-data --single-transaction --quick --skip-add-locks --skip-lock-tables --default-character-set=utf8 --compress myappdb"
          expect(executor).to receive(:ssh_command).with(dump, 'my.db.host')
          copier.copy!
        end
      end
    end

    context "with a non-standard mysql port" do
      let(:params) { super().merge(:port => 3307) }

      it "issues mysqldump over ssh" do
        dump = "mysqldump -P 3307  -u root -p supersekrit -h my.db.host --master-data --single-transaction --quick --skip-add-locks --skip-lock-tables --default-character-set=utf8 --compress myappdb"
        expect(executor).to receive(:ssh_command).with(dump, 'my.db.host')
        copier.copy!
      end
    end

    context "with a socket file" do
      let(:params) { super().merge(:socket_file => "/tmp/mysql.sock") }

      it "issues mysqldump over ssh" do
        dump = "mysqldump -S /tmp/mysql.sock -u root -p supersekrit -h my.db.host --master-data --single-transaction --quick --skip-add-locks --skip-lock-tables --default-character-set=utf8 --compress myappdb"
        expect(executor).to receive(:ssh_command).with(dump, 'my.db.host')
        copier.copy!
      end

      it "loads data" do
        dump_and_load = "dummy-ssh-command | mysql -S /tmp/mysql.sock -u root -p supersekrit myappdb"
        expect(executor).to receive(:execute).once.ordered.with(dump_and_load)
        copier.copy!
      end

    end
  end
end
