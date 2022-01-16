use Cro::HTTP::Client;
use WebService::HashiCorp::Vault::KeyStatus;
use WebService::HashiCorp::Vault::SecretV1;

constant $defaultURL = 'http://127.0.0.1:8200';

#| A client for communicating with the Vault API
class Client {
    has $!baseURL;
    has Str $!token;

    multi method baseURL {
        $!baseURL;
    }

    multi method baseURL($url) {
        $!baseURL = $url;
    }

    multi method token {
        $!token;
    }

    multi method token($aToken) {
        $!token = $aToken;
    }

    submethod BUILD(:$!baseURL, Str :$!token) {
        my (:$VAULT_ADDR, :$VAULT_TOKEN, *%) := %*ENV;
        unless defined $!baseURL {
            if defined $VAULT_ADDR {
                $!baseURL = $VAULT_ADDR;
            } else {
                $!baseURL ||= $defaultURL;
            }
        }

        if defined $VAULT_TOKEN { $!token = $VAULT_TOKEN; }
    }

    #| Query for encyryption key status
    method getEncryptionKeyStatus() {
        my $ks = KeyStatus.new();
        my $status = $ks.getKeyStatus(baseURL=>$!baseURL,
            tkn=>$!token);

        $status;
    }

    method getSecret(Str :$vault!, Str :$key!) {
        my $k1 = SecretV1.new();
        $k1.getSecret(
            baseURL=>$!baseURL,
            tkn=>$!token,
            vault=>$vault,
            key=>$key
        );
        
        $k1;
    }

    method isInitialized() returns Bool {
        my $endpoint = "$!baseURL/v1/sys/init";
        my $response = await Cro::HTTP::Client.get($endpoint);
        CATCH {
            when X::Cro::HTTP::Error {
                say "Error Response: "
                    ~ .response.status 
                    ~ " when performing GET on target "
                    ~ .request.target;
            }
        }

        my $json = await $response.body;
        $json{ 'initialized' };
    }

    method isSealed() {
        my $endpoint = "$!baseURL/v1/sys/seal-status";
        my $client = Cro::HTTP::Client.new(
            headers => [
                X-Vault-Token => $!token
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
        $json{'sealed'}
    }

    method listSecrets(Str :$vault!) {
        my $k1 = SecretV1.new();
        $k1.listSecrets(
            baseURL=>$!baseURL,
            tkn=>$!token,
            vault=>$vault
        );
    }

    multi method unseal(:@keys!) returns Bool {
        my ($stat, $result);

        for @keys -> $key {
            ($stat, $result) = self.unseal(key => $key);
            last unless ($stat == 200);
        }

        given $stat {
            when 200 {
                !$result{'sealed'}
            }
            default { False; }
        }
    }

    multi method unseal(Str :$key!) {
        my $endpoint = "$!baseURL/v1/sys/unseal";
        my %content = key => "$key";
        my $response = await Cro::HTTP::Client.post: $endpoint,
            content-type => 'application/json',
            body => %content;
        CATCH {
            when X::Cro::HTTP::Error {
                say "Error Response: "
                    ~ .response.status 
                    ~ " when performing GET on target "
                    ~ .request.target;
            }
        }

        my $json = await $response.body;
        $response.status, $json;
    }
}
