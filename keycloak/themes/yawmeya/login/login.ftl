<!DOCTYPE html>
<html lang="${locale.current}"<#if realm.internationalizationEnabled> dir="${(locale.rtl)?then('rtl','ltr')}"</#if>>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="robots" content="noindex, nofollow">
    
    <title>${msg("loginTitle",(realm.displayName!''))}</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=IBM+Plex+Sans+Arabic:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <#if properties.styles?has_content>
        <#list properties.styles?split(' ') as style>
            <link href="${url.resourcesPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>
    
    <script>
        // Theme initialization
        (function() {
            const theme = localStorage.getItem('theme');
            if (theme === 'dark' || (!theme && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
                document.documentElement.classList.add('dark');
            }
        })();
    </script>
</head>

<body>
    <div id="kc-container-wrapper">
        <div id="kc-content">
            <!-- Theme Toggle & Language Switcher -->
            <div id="kc-controls">
                <!-- Theme Toggle -->
                <button id="theme-toggle" class="control-button" aria-label="${msg("toggleTheme")}">
                    <svg id="sun-icon" class="control-icon hidden" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v2.25m6.364.386-1.591 1.591M21 12h-2.25m-.386 6.364-1.591-1.591M12 18.75V21m-4.773-4.227-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0Z" />
                    </svg>
                    <svg id="moon-icon" class="control-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21.752 15.002A9.72 9.72 0 0 1 18 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 0 0 3 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 0 0 9.002-5.998Z" />
                    </svg>
                </button>
                
                <!-- Language Toggle -->
                <#if realm.internationalizationEnabled && locale.supported?size gt 1>
                    <#list locale.supported as l>
                        <#if l.languageTag != locale.current>
                            <a href="${l.url}" class="control-button lang-button" aria-label="${msg("toggleLanguage")}">
                                <svg class="control-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 21l5.25-11.25L21 21m-9-3h7.5M3 5.621a48.474 48.474 0 016-.371m0 0c1.12 0 2.233.038 3.334.114M9 5.25V3m3.334 2.364C11.176 10.658 7.69 15.08 3 17.502m9.334-12.138c.896.061 1.785.147 2.666.257m-4.589 8.495a18.023 18.023 0 01-3.827-5.802" />
                                </svg>
                            </a>
                            <#break> 
                        </#if>
                    </#list>
                </#if>
            </div>
            
            <script>
                // Theme toggle functionality
                const themeToggle = document.getElementById('theme-toggle');
                const sunIcon = document.getElementById('sun-icon');
                const moonIcon = document.getElementById('moon-icon');
                const html = document.documentElement;
                
                function updateIcons() {
                    if (html.classList.contains('dark')) {
                        sunIcon.classList.remove('hidden');
                        moonIcon.classList.add('hidden');
                    } else {
                        sunIcon.classList.add('hidden');
                        moonIcon.classList.remove('hidden');
                    }
                }
                
                updateIcons();
                
                themeToggle.addEventListener('click', function() {
                    html.classList.toggle('dark');
                    localStorage.setItem('theme', html.classList.contains('dark') ? 'dark' : 'light');
                    updateIcons();
                });
            </script>

            <!-- Header -->
            <div id="kc-header">
                <div id="kc-header-wrapper">
                    <div class="logo-icon">
                        <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z" />
                        </svg>
                    </div>
                    <span class="logo-text">${msg("appName")}</span>
                </div>
            </div>

            <!-- Alert Messages -->
            <#if message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
                <div class="alert alert-${message.type}">
                    <#if message.type = 'success'><span class="alert-icon">✓</span></#if>
                    <#if message.type = 'error'><span class="alert-icon">✕</span></#if>
                    ${kcSanitize(message.summary)?no_esc}
                </div>
            </#if>

            <!-- Login Form -->
            <div id="kc-form">
                <div id="kc-form-wrapper">
                    <#if realm.password>
                        <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">
                            <!-- Username Field -->
                            <div class="form-group">
                                <label for="username" class="control-label">
                                    <#if !realm.loginWithEmailAllowed>
                                        ${msg("username")}
                                    <#elseif !realm.registrationEmailAsUsername>
                                        ${msg("usernameOrEmail")}
                                    <#else>
                                        ${msg("email")}
                                    </#if>
                                </label>

                                <input tabindex="1" 
                                       id="username" 
                                       class="form-control" 
                                       name="username" 
                                       value="${(login.username!'')}"  
                                       type="text" 
                                       autofocus 
                                       autocomplete="username"
                                       placeholder="${msg('enterUsername')}"
                                       aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>" />

                                <#if messagesPerField.existsError('username','password')>
                                    <span id="input-error" class="error-message" aria-live="polite">
                                        ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                                    </span>
                                </#if>
                            </div>

                            <!-- Password Field -->
                            <div class="form-group">
                                <label for="password" class="control-label">${msg("password")}</label>
                                
                                <input tabindex="2" 
                                       id="password" 
                                       class="form-control" 
                                       name="password" 
                                       type="password" 
                                       autocomplete="current-password"
                                       placeholder="${msg('enterPassword')}"
                                       aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>" />
                            </div>

                            <!-- Remember Me -->
                            <#if realm.rememberMe && !usernameHidden??>
                                <div id="kc-form-options">
                                    <div class="checkbox">
                                        <label>
                                            <input tabindex="3" 
                                                   id="rememberMe" 
                                                   name="rememberMe" 
                                                   type="checkbox" 
                                                   <#if login.rememberMe??>checked</#if>> 
                                            ${msg("rememberMe")}
                                        </label>
                                    </div>
                                </div>
                            </#if>

                            <!-- Submit Button -->
                            <div id="kc-form-buttons">
                                <input type="hidden" 
                                       id="id-hidden-input" 
                                       name="credentialId" 
                                       <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                                
                                <button tabindex="4" 
                                        class="btn-primary" 
                                        name="login" 
                                        id="kc-login" 
                                        type="submit">
                                    ${msg("doLogIn")}
                                </button>
                            </div>

                            <!-- Reset Password Link -->
                            <#if realm.resetPasswordAllowed>
                                <div class="link-wrapper">
                                    <a tabindex="5" href="${url.loginResetCredentialsUrl}">
                                        ${msg("doForgotPassword")}
                                    </a>
                                </div>
                            </#if>

                            <!-- Registration Link -->
                            <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
                                <div id="kc-registration">
                                    <span class="registration-text">
                                        ${msg("noAccount")} 
                                        <a tabindex="6" href="${url.registrationUrl}">
                                            ${msg("doRegister")}
                                        </a>
                                    </span>
                                </div>
                            </#if>
                        </form>
                    </#if>
                </div>

                <!-- Social Providers (only shown if social providers exist) -->
                <#if realm.password && social.providers?? && social.providers?has_content>
                    <div id="kc-social-providers">
                        <div class="social-separator">
                            <span>${msg("identity-provider-login-label")}</span>
                        </div>
                        <ul class="social-providers-list">
                            <#list social.providers as p>
                                <li>
                                    <a id="social-${p.alias}" 
                                       class="btn-social" 
                                       type="button" 
                                       href="${p.loginUrl}">
                                        <#if p.iconClasses?has_content>
                                            <i class="${p.iconClasses!}" aria-hidden="true"></i>
                                        </#if>
                                        <span>${p.displayName!}</span>
                                    </a>
                                </li>
                            </#list>
                        </ul>
                    </div>
                </#if>

            </div>
        </div>
    </div>
</body>
</html>