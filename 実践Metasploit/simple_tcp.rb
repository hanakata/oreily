#Metasploit
class MetasploitModule < MSF::Auxiliary
    # ミックスインを使ってTCPネットワーキング処理を実施
    include Msf::Exploit::Remote::Tcp
    # ミックスインを使ってスキャナに必要なものを利用できるようにする。
    include Msf::Auxiliary::Scanner
    def initialize
        super(
            'Name' => 'My custom TCP scan',
            'Version' => '$Revision:1 $',
            'Description' => 'My quick scanner',
            'License' => MSF_LICENSE
        )
        register_options(
            [
                # デフォルトポートの指定
                Opt::RPORT(12345)
            ],self.class
        )
    end

    def run_host(ip)
        connect()
        # 対象にメッセージ送信
        sock.put('HELLO SERVER')
        data = sock.recv(1024)
        # 応答を受け取りIPとともに画面に表示
        print_status("Receivd: #{data} from #{ip}")
        disconnect()
    end
end