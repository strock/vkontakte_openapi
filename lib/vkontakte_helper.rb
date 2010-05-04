module VKontakteHelper
	include VKontakte::Utilities

	def vk_login path = '/sessions/vk'
		<<-VK
		<div id="vk_api_transport"></div>
		<script type="text/javascript">
		  window.vkAsyncInit = function() {
		        VK.Observer.subscribe('auth.login', function(response) {
		          window.location = '#{url_for path}';
		        });
		    VK.init({
		      apiId: #{Settings.get[:app_id]},
		      nameTransportPath: "/xd_receiver.html"
		    });
		    VK.UI.button('vk_login');
		  };

		  (function() {
		    var el = document.createElement("script");
		    el.type = "text/javascript";
		    el.charset = "windows-1251";
		    el.src = "http://vkontakte.ru/js/api/openapi.js";
		    el.async = true;
		    document.getElementById("vk_api_transport").appendChild(el);
		  }());
		</script>
		<div id="vk_login" style="margin: 0 auto 20px auto;" onclick="doLogin();"></div>
		VK
	end
end	

