package intersystems.ensemble;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.Security;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.eclipse.milo.opcua.sdk.client.OpcUaClient;
import org.eclipse.milo.opcua.stack.core.Stack;
import org.eclipse.milo.opcua.stack.core.types.builtin.LocalizedText;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.util.function.Predicate;
import org.eclipse.milo.opcua.sdk.client.api.identity.AnonymousProvider;
import org.eclipse.milo.opcua.sdk.client.api.identity.IdentityProvider;
import org.eclipse.milo.opcua.stack.core.security.SecurityPolicy;
import org.eclipse.milo.opcua.stack.core.types.structured.EndpointDescription;

import intersystems.ensemble.KeyStoreLoader;

import static org.eclipse.milo.opcua.stack.core.types.builtin.unsigned.Unsigned.uint;

public class ConnectionClearing {


    public ConnectionClearing() {
        // Required for SecurityPolicy.Aes256_Sha256_RsaPss
        Security.addProvider(new BouncyCastleProvider());
    }

    private final Logger logger = LoggerFactory.getLogger(getClass());

//    private CompletableFuture<OpcUaClient> future = new CompletableFuture<>();

    public Predicate<EndpointDescription> endpointFilter() {
        return e -> true;
    }

    public SecurityPolicy getSecurityPolicy() {
        return SecurityPolicy.None;
    }

    public IdentityProvider getIdentityProvider() {
        return new AnonymousProvider();
    }


    public OpcUaClient createClient(String url, String AppUri) throws Exception {
        final Path securityTempDir = Paths.get(System.getProperty("java.io.tmpdir"), "security");
        Files.createDirectories(securityTempDir);
        if (!Files.exists(securityTempDir)) {
            throw new Exception("unable to create security dir: " + securityTempDir);
        }

        LoggerFactory.getLogger(getClass()).info("security temp dir: {}", securityTempDir.toAbsolutePath());

        final KeyStoreLoader loader = new KeyStoreLoader().load(securityTempDir);

        return OpcUaClient.create(url,
                endpoints -> endpoints.stream().filter(endpointFilter()).findFirst(),
                configBuilder -> configBuilder.setApplicationName(LocalizedText.english("eclipse milo opc-ua client"))
                        .setApplicationUri(AppUri)
                        .setCertificate(loader.getClientCertificate()).setKeyPair(loader.getClientKeyPair())
                        .setIdentityProvider(getIdentityProvider()).setRequestTimeout(uint(5000))
                        .build());
    }

    public void connect(OpcUaClient client) throws InterruptedException,ExecutionException{
        client.connect().get();
    }

    public void disconnect(OpcUaClient client) throws InterruptedException,ExecutionException{
        client.disconnect().get();
        Stack.releaseSharedResources();
    }
    
}