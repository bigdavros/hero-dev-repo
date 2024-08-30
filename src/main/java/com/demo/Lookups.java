package com.demo;

import com.google.api.client.json.webtoken.JsonWebToken;
import com.google.auth.oauth2.TokenVerifier;

public class Lookups {

        public String verifyJwt(String jwtToken) {
        String audience = System.getenv("IAPBACKEND");
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
    
}
