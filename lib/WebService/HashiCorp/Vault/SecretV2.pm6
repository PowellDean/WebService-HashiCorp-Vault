use Cro::HTTP::Client;

class SecretV2 {
    has Str $!k;
    has Str $!v;
    has Int $!leaseDuration;
    has Bool $!renewable;
    has Str $!requestId;
    has Str $!createdTime;
    has Str $!deletionTime;
    has Bool $!destroyed;
    has Int $!version;

    multi method k {
        $!k;
    }

    multi method k($aString) {
        $!k = $aString;
    }

    multi method v {
        $!v;
    }

    multi method v($aString) {
        $!v = $aString;
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

    multi method createdTime {
        $!createdTime;
    }

    multi method createdTime(Str $aUTCTime) {
        $!createdTime = $aUTCTime
    }

    multi method deletionTime {
        $!deletionTime;
    }

    multi method deletionTime(Str $aUTCTime) {
        $!deletionTime = $aUTCTime
    }

    multi method destroyed {
        $!destroyed;
    }

    multi method destroyed(Bool $anIndicator) {
        $!destroyed = $anIndicator;
    }

    multi method version{
        $!version;
    }

    multi method version(Int $aVersionNumber) {
        $!version = $aVersionNumber;
    }

    submethod BUILD(
        :$!k='',
        :$!v='',
        :$!leaseDuration=0,
        :$!renewable=False,
        :$!requestId='',
        :$!createdTime='',
        :$!deletionTime='',
        :$!destroyed=False,
        :$!version=0) {
    }

    method getSecret(Str :$baseURL!, Str :$tkn!, Str :$vault!, Str :$key!) {
        my $endpoint = "$baseURL/v1/$vault/data/$key";
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
        say $json;
        self.leaseDuration: $json{'lease_duration'};
        self.renewable:     $json{'renewable'};
        self.requestId:     $json{'request_id'};
        self.createdTime:   $json{'data'}{'metadata'}{'created_time'};
        self.deletionTime:  $json{'data'}{'metadata'}{'deletion_time'};
        self.destroyed:     $json{'data'}{'metadata'}{'destroyed'};
        self.version:       $json{'data'}{'metadata'}{'version'};

        my %kvPair = $json{'data'}{'data'};
        self.k:  %kvPair.keys[0];
        self.v:  %kvPair{self.k};

        self;
    }

    method listSecrets(Str :$baseURL!, Str :$tkn!, Str :$vault!) {
        my $endpoint = "$baseURL/v1/$vault?list=true";
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
        say $json;
        my @secrets = list($json{'data'}{'keys'});

        @secrets;
    }
}
