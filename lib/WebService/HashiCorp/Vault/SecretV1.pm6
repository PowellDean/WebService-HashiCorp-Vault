use Cro::HTTP::Client;

class SecretV1 {
    has Str $!k;
    has Str $!v;
    has Int $!leaseDuration;
    has Bool $!renewable;
    has Str $!requestId;

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

    submethod BUILD(
        :$!k='',
        :$!v='',
        :$!leaseDuration=0,
        :$!renewable=False,
        :$!requestId='' ) {
    }

    method getSecret(Str :$baseURL!, Str :$tkn!, Str :$vault!, Str :$key!) {
        my $endpoint = "$baseURL/v1/$vault/$key";
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

        my %kvPair = $json{'data'};
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
