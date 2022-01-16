use Cro::HTTP::Client;

=begin pod
=begin head1
A Vault KeyStatus object
=end head1

=begin head2
Attributes:
=end head2

=defn encryptions
No clue what this actually is

=end pod

#| A KeyStatus is the object returned when querying for the status of
#| a given Vault key
class KeyStatus {
    has Int $!encryptions;
    has Str $!installTime;
    has Int $!leaseDuration;
    has Bool $!renewable;
    has Str $!requestId;

    multi method encryptions {
        $!encryptions;
    }

    multi method encryptions($aNumber) {
        $!encryptions = $aNumber;
    }

    multi method installTime {
        $!installTime;
    }

    multi method installTime($aString) {
        $!installTime = $aString
    }

    multi method leaseDuration {
        $!leaseDuration;
    }

    multi method leaseDuration($aNumber) {
        $!leaseDuration = $aNumber;
    }

    multi method renewable {
        $!renewable;
    }

    multi method renewable($aBool) {
        $!renewable = $aBool;
    }

    multi method requestId {
        $!requestId;
    }

    multi method requestId(Str $aString) {
        $!requestId = $aString;
    }

    submethod BUILD(
        :$!encryptions=0,
        :$!installTime='',
        :$!leaseDuration=0,
        :$!renewable=True,
        :$!requestId='') {
    }

    method getKeyStatus(Str :$baseURL!, Str :$tkn!) {
        my $endpoint = "$baseURL/v1/sys/key-status";
        my $client = Cro::HTTP::Client.new(
            headers => [
                X-Vault-Token => $tkn
            ]);

        my $response = await $client.get($endpoint);
        CATCH {
            when X::Cro::HTTP::Error {
                say "Error Response: "
                    ~ .response.status 
                    ~ " when performing GET on target "
                    ~ .request.target;
            }
        }

        my $json = await $response.body;

        self.encryptions:   $json{'encryptions'};
        self.installTime:   $json{'install_time'};
        self.leaseDuration: $json{'lease_duration'};
        self.renewable:     $json{'renewable'};
        self.requestId:     $json{'request_id'};

        self;
    }
}
