package com.project.myapp.security.config;

import java.util.Collections;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.oauth2.client.InMemoryOAuth2AuthorizedClientService;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientService;
import org.springframework.security.oauth2.client.endpoint.DefaultAuthorizationCodeTokenResponseClient;
import org.springframework.security.oauth2.client.endpoint.OAuth2AccessTokenResponseClient;
import org.springframework.security.oauth2.client.endpoint.OAuth2AuthorizationCodeGrantRequest;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.oauth2.client.registration.InMemoryClientRegistrationRepository;
import org.springframework.security.oauth2.client.web.AuthorizationRequestRepository;
import org.springframework.security.oauth2.client.web.HttpSessionOAuth2AuthorizationRequestRepository;
import org.springframework.security.oauth2.core.AuthorizationGrantType;
import org.springframework.security.oauth2.core.endpoint.OAuth2AuthorizationRequest;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.expression.DefaultWebSecurityExpressionHandler;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.logout.LogoutFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

import com.project.myapp.properties.OAuth2Properties;
import com.project.myapp.security.jwt.JwtFilter;
import com.project.myapp.security.jwt.JwtUtil;
import com.project.myapp.security.jwt.LoginFilter;
import com.project.myapp.security.jwt.mapper.RefreshMapper;
import com.project.myapp.security.oauth.handler.CustomLogoutFilter;
import com.project.myapp.security.oauth.handler.CustomSuccessHandler;
import com.project.myapp.security.oauth.service.CustomOAuth2UserService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@EnableWebMvc
@Configuration
@EnableWebSecurity    // non-Boot 에서는 @EnableWebSecurity 어노테이션 추가해도 web.xml에 반드시 필터 추가 해줘야 작동한다.
@RequiredArgsConstructor
@MapperScan("com.project.myapp.security.jwt.mapper")
@EnableGlobalMethodSecurity(securedEnabled = true, prePostEnabled = true)
@ComponentScan(basePackages = {"com.project.myapp", "com.project.myapp.security.**"})
public class SecurityConfig {

	private final JwtUtil jwtUtil;
	private final RefreshMapper refreshMapper;
	private final OAuth2Properties oAuth2Properties;
	private final CustomSuccessHandler customSuccessHandler;
	private final CustomOAuth2UserService customOAuth2UserService;
	private final AuthenticationConfiguration authenticationConfiguration;

	@Bean
	public AuthenticationManager authenticationManager(AuthenticationConfiguration configuration) throws Exception {
		return configuration.getAuthenticationManager();
	}

	@Bean
	public DefaultWebSecurityExpressionHandler webSecurityExpressionHandler() {
		return new DefaultWebSecurityExpressionHandler();
	}

	@Bean
	public static BCryptPasswordEncoder bCryptPasswordEncoder() {
		return new BCryptPasswordEncoder();
	}

	@Bean
	public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

		CorsConfiguration configuration = new CorsConfiguration();
		configuration.setAllowedOrigins(Collections.singletonList("http://localhost:8080/*"));
		configuration.setAllowedHeaders(Collections.singletonList("*"));
		configuration.setAllowedMethods(Collections.singletonList("*"));
		configuration.setExposedHeaders(Collections.singletonList("access"));
		configuration.setAllowCredentials(true);
		configuration.setMaxAge(3600L);

		UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
		source.registerCorsConfiguration("/**", configuration);
		http.cors().configurationSource(source);

		http.csrf(AbstractHttpConfigurer::disable);
		http.formLogin().disable();
		http.httpBasic().disable();
		http.authorizeHttpRequests((auth) -> auth
			.requestMatchers("/js/**").permitAll()
			.requestMatchers("/css/**").permitAll()
			.requestMatchers("/bootstrap/**").permitAll()
			.requestMatchers("/jwtLogin").permitAll()
			.requestMatchers("/reissue").permitAll()
			.requestMatchers("/login/loginForm").permitAll()
			.requestMatchers("/generalLogin").authenticated()
			.requestMatchers("/login").authenticated()
			.requestMatchers("/**").permitAll()
			.anyRequest().authenticated()
		);

		// http
		// 	.addFilterAt(new LoginFilter(authenticationManager(authenticationConfiguration), jwtUtil),
		// 		UsernamePasswordAuthenticationFilter.class)
		// 	.addFilterBefore(new JwtFilter(jwtUtil), UsernamePasswordAuthenticationFilter.class);

		// http
		// 	.addFilterBefore(new LoginFilter(authenticationManager(authenticationConfiguration), jwtUtil),
		// 		UsernamePasswordAuthenticationFilter.class);
		// http.addFilterAfter(new JwtFilter(jwtUtil), UsernamePasswordAuthenticationFilter.class);

		// http.addFilterAt(new LoginFilter(authenticationManager(authenticationConfiguration), jwtUtil),
		// 	UsernamePasswordAuthenticationFilter.class);
		// http.addFilterAt(new JwtFilter(jwtUtil), UsernamePasswordAuthenticationFilter.class);
		http.addFilterBefore(
				new LoginFilter(authenticationManager(authenticationConfiguration), refreshMapper, jwtUtil),
				UsernamePasswordAuthenticationFilter.class)
			.addFilterAfter(new JwtFilter(jwtUtil), LoginFilter.class);

		http.addFilterBefore(new CustomLogoutFilter(jwtUtil, refreshMapper), LogoutFilter.class);

		http.oauth2Login((oauth2) -> oauth2
			.userInfoEndpoint((userInfoEndpointConfig) -> userInfoEndpointConfig
				.userService(customOAuth2UserService))
			.successHandler(customSuccessHandler)
			.clientRegistrationRepository(clientRegistrationRepository())
		);

		http.sessionManagement((session) -> session
			.sessionCreationPolicy(SessionCreationPolicy.STATELESS));

		return http.build();
	}

	@Bean
	public AuthorizationRequestRepository<OAuth2AuthorizationRequest> authorizationRequestRepository() {
		return new HttpSessionOAuth2AuthorizationRequestRepository();
	}

	@Bean
	public OAuth2AccessTokenResponseClient<OAuth2AuthorizationCodeGrantRequest> accessTokenResponseClient() {
		DefaultAuthorizationCodeTokenResponseClient accessTokenResponseClient = new DefaultAuthorizationCodeTokenResponseClient();
		return accessTokenResponseClient;
	}

	@Bean
	public ClientRegistrationRepository clientRegistrationRepository() {

		ClientRegistration googleClientRegistration = ClientRegistration.withRegistrationId("google")
			.clientId(oAuth2Properties.getGoogle_client_id())
			.clientSecret(oAuth2Properties.getGoogle_client_secret())
			.scope(oAuth2Properties.getScope())
			.authorizationGrantType(AuthorizationGrantType.AUTHORIZATION_CODE)
			.redirectUri(oAuth2Properties.getGoogle_redirect_uri())
			.authorizationUri("https://accounts.google.com/o/oauth2/v2/auth")
			.tokenUri("https://www.googleapis.com/oauth2/v4/token")
			.jwkSetUri("https://www.googleapis.com/oauth2/v3/certs")
			.userNameAttributeName("sub")
			.issuerUri("https://accounts.google.com")
			.userInfoUri("https://www.googleapis.com/oauth2/v3/userinfo")
			.clientName("Google")
			.build();

		return new InMemoryClientRegistrationRepository(googleClientRegistration);

	}

	@Bean
	public OAuth2AuthorizedClientService authorizedClientService() {
		return new InMemoryOAuth2AuthorizedClientService(clientRegistrationRepository());
	}
}