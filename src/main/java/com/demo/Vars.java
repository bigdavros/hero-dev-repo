package com.demo;
/* Copyright 2023 Google LLC

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

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
        out.println("let username = \"user@example.com\";");
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
