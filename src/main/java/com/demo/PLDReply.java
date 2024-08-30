package com.demo;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;

public class PLDReply {
    private Boolean pldResult;
    Reply reply;
    
    public void setPldResult(Boolean pldResult) {
        this.pldResult = pldResult;
    }

    public Boolean getPldResult() {
        return pldResult;
    }

    public void setReply(Reply reply) {
        this.reply = reply;
    }

    public Reply getReply() {
        return reply;
    }

    public String asJSON() throws Exception{
        String json;
        try {
            ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
            json = ow.writeValueAsString(this);
        }
        finally{}
        return json;
    }
}
