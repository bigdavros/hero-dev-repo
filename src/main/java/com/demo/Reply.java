package com.demo;

import java.util.Base64;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;

public class Reply{
    private String data = Base64.getEncoder().encodeToString("Error. Default value unchanged.".getBytes());
    private String result = Base64.getEncoder().encodeToString("Error. Default value unchanged.".getBytes());;

    public void setData (String data){
        this.data = Base64.getEncoder().encodeToString(data.toString().getBytes());
    }

    public void setResult (String result) {
        this.result = Base64.getEncoder().encodeToString(result.toString().getBytes());
    }

    public String getData(){
        return data;
    }

    public String getResult(){
        return result;
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
