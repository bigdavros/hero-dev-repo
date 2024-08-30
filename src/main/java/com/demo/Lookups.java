package com.demo;


import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.codec.binary.Hex;

import com.google.api.client.json.webtoken.JsonWebToken;
import com.google.auth.oauth2.TokenVerifier;

public class Lookups {

    private final String defaultHashedAccountId = "024ffeebf3d629d24bdc5a148a91f22b811b7e3c1646624e12d91baa0ef1580f";

    public String getHashedAccountId(String data) throws Exception {
        String key = System.getenv("HASHEDIDSALT");
        Mac sha256_HMAC = Mac.getInstance("HmacSHA256");
        SecretKeySpec secret_key = new SecretKeySpec(key.getBytes("UTF-8"), "HmacSHA256");
        sha256_HMAC.init(secret_key);        
        return Hex.encodeHexString(sha256_HMAC.doFinal(data.getBytes("UTF-8")));
    }

    public String verifyJwt(String jwtToken) {
        String audience = System.getenv("IAPAUDIENCE");
        TokenVerifier tokenVerifier =
            TokenVerifier.newBuilder().setAudience(audience).setIssuer("https://cloud.google.com/iap").build();
        try {
            JsonWebToken jsonWebToken = tokenVerifier.verify(jwtToken);
            JsonWebToken.Payload payload = jsonWebToken.getPayload();
            return payload.get("email").toString();
        } catch (TokenVerifier.VerificationException e) {
            System.out.println(e.getMessage());
            return null;
        }
    }

    public String getDefaultHashedAccountId() {
        return defaultHashedAccountId;
    }
    
}
