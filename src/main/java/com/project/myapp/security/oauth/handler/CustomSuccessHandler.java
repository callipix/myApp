package com.project.myapp.security.oauth.handler;

import java.io.IOException;
import java.util.Collection;
import java.util.Date;
import java.util.Iterator;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import com.project.myapp.dto.RefreshDTO;
import com.project.myapp.security.auth.CustomDetails;
import com.project.myapp.security.jwt.JwtUtil;
import com.project.myapp.security.jwt.mapper.RefreshMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
@RequiredArgsConstructor
@MapperScan("com.project.myapp.security.jwt.mapper")
public class CustomSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

	private final JwtUtil jwtUtil;
	private final RefreshMapper refreshMapper;

	@Override
	public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
		Authentication authentication) throws IOException, ServletException {

		log.info("여길 안와?");
		CustomDetails customUserDetails = (CustomDetails)authentication.getPrincipal();
		log.info("customUserDetails = {}", customUserDetails);

		String username = customUserDetails.getUsername();
		log.info("username for onAuthenticationSuccess = {}", username);

		Collection<? extends GrantedAuthority> authorities = authentication.getAuthorities();
		Iterator<? extends GrantedAuthority> iterator = authorities.iterator();
		GrantedAuthority auth = iterator.next();

		String role = auth.getAuthority();

		String access = jwtUtil.createJwt("access", username, role, 6000000L);
		String refresh = jwtUtil.createJwt("refresh", username, role, 86400000L);

		// String access = jwtUtil.createJwt("access", username, role, 600000L);
		// String refresh = jwtUtil.createJwt("refresh", username, role, 86400000L);
		// String token = jwtUtil.createJwt(username, role, 60 * 60 * 60L);

		addRefreshToken(username, refresh, 86400000L);

		log.info("CustomSuccessHandler 끝");
		response.addHeader("access", access);
		// response.addCookie(createCookie("access", token));
		response.addCookie(createCookie("access", access));
		response.addCookie(createCookie("refresh", refresh));
		response.sendRedirect("/addToken");
	}

	private Cookie createCookie(String key, String value) {
		Cookie cookie = new Cookie(key, value);
		cookie.setMaxAge(60 * 60 * 60);
		cookie.setPath("/");
		// cookie.setSecure(true);
		// setSecure 사용하면 https 프로토콜로만 전송 가능
		cookie.setHttpOnly(true);

		return cookie;
	}

	private void addRefreshToken(String username, String refresh, Long expiredMs) {
		Date dateByOAuth2 = new Date(System.currentTimeMillis() + expiredMs);
		int result = 0;

		RefreshDTO refreshDTO = new RefreshDTO();
		refreshDTO.setRefresh(refresh);
		refreshDTO.setUsername(username);
		refreshDTO.setExpiration(dateByOAuth2.toString());

		log.info("refreshDTO = {}", refreshDTO);
		result += this.refreshMapper.insertSave(refreshDTO);
		log.info("result for addRefreshToken = {}", result);

	}

}