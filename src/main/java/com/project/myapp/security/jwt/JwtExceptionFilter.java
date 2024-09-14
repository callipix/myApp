package com.project.myapp.security.jwt;

import java.io.IOException;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.filter.OncePerRequestFilter;

public class JwtExceptionFilter extends OncePerRequestFilter {

	@Override
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
		FilterChain filterChain) throws ServletException, IOException {

		response.setCharacterEncoding("utf-8");

		try {
			filterChain.doFilter(request, response);
		} catch (Exception e) {
			request.setAttribute("exception", e.getMessage());
		}
		filterChain.doFilter(request, response);

	}
}