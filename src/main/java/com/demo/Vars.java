package com.demo;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = "/js/vars.js")
public class Vars extends HttpServlet {      
      
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        PrintWriter out = resp.getWriter();
        String username = "container@localhost";
        String jwtToken = req.getHeader("x-goog-iap-jwt-assertion");
        Lookups lookup = new Lookups();
        if(jwtToken!=null){          
            if(lookup.verifyJwt(jwtToken)!=null){
                username = lookup.verifyJwt(jwtToken);
            }
        }
        else{
            out.println("// no x-goog-iap-jwt-assertion");
        }

        out.println("let username = \""+username+"\";");
        out.println("let v3_site_key = \""+System.getenv("V3KEY")+"\";");
        out.println("let test_0_2_site_key = \""+System.getenv("TEST2KEY")+"\";");
        out.println("let test_0_8_site_key = \""+System.getenv("TEST8KEY")+"\";");
        out.println("let v2_site_key = \""+System.getenv("V2KEY")+"\";");
        out.println("let lastBuild = \""+System.getenv("LASTBUILD")+"\";");
        
    }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    }
}
