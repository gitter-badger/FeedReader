//	This file is part of FeedReader.
//
//	FeedReader is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	FeedReader is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with FeedReader.  If not, see <http://www.gnu.org/licenses/>.

public class FeedReader.freshUtils : GLib.Object {

	GLib.Settings m_settings;

	public freshUtils()
	{
		m_settings = new GLib.Settings("org.gnome.feedreader.fresh");
	}

	public string getURL()
	{
		string tmp_url = m_settings.get_string("url");
		if(tmp_url != "")
		{
			if(!tmp_url.has_suffix("/"))
				tmp_url = tmp_url + "/";

			if(!tmp_url.has_suffix("/api/greader.php/"))
				tmp_url = tmp_url + "api/greader.php/";

			if(!tmp_url.has_prefix("http://") && !tmp_url.has_prefix("https://"))
					tmp_url = "https://" + tmp_url;
		}

		return tmp_url;
	}

	public void setURL(string url)
	{
		m_settings.set_string("url", url);
	}

	public string getUser()
	{
		return m_settings.get_string("username");
	}

	public void setToken(string token)
	{
		m_settings.set_string("token", token);
	}

	public string getToken()
	{
		return m_settings.get_string("token");
	}

	public void setUser(string user)
	{
		m_settings.set_string("username", user);
	}

	public string getHtaccessUser()
	{
		return m_settings.get_string("htaccess-username");
	}

	public void setHtaccessUser(string ht_user)
	{
		m_settings.set_string("htaccess-username", ht_user);
	}

	public string getUnmodifiedURL()
	{
		return m_settings.get_string("url");
	}

	public string getPasswd()
	{
		var pwSchema = new Secret.Schema ("org.gnome.feedreader.password", Secret.SchemaFlags.NONE,
		                                  "URL", Secret.SchemaAttributeType.STRING,
		                                  "Username", Secret.SchemaAttributeType.STRING);

		var attributes = new GLib.HashTable<string,string>(str_hash, str_equal);
		attributes["URL"] = getURL();
		attributes["Username"] = getUser();

		string passwd = "";

		try{
			passwd = Secret.password_lookupv_sync(pwSchema, attributes, null);
		}
		catch(GLib.Error e){
			Logger.error(e.message);
		}

		if(passwd == null)
		{
			return "";
		}

		return passwd;
	}

	public void setPassword(string passwd)
	{
		var pwSchema = new Secret.Schema ("org.gnome.feedreader.password", Secret.SchemaFlags.NONE,
										  "URL", Secret.SchemaAttributeType.STRING,
										  "Username", Secret.SchemaAttributeType.STRING);
		var attributes = new GLib.HashTable<string,string>(str_hash, str_equal);
		attributes["URL"] = getURL();
		attributes["Username"] = getUser();
		try
		{
			Secret.password_storev_sync(pwSchema, attributes, Secret.COLLECTION_DEFAULT, "FeedReader: freshRSS login", passwd, null);
		}
		catch(GLib.Error e)
		{
			Logger.error("freshUtils: setPassword: " + e.message);
		}
	}

	public void resetAccount()
	{
		Utils.resetSettings(m_settings);
		deletePassword();
	}

	public bool deletePassword()
	{
		bool removed = false;
		var pwSchema = new Secret.Schema ("org.gnome.feedreader.password", Secret.SchemaFlags.NONE,
										"URL", Secret.SchemaAttributeType.STRING,
										"Username", Secret.SchemaAttributeType.STRING);
		var attributes = new GLib.HashTable<string,string>(str_hash, str_equal);
		attributes["URL"] = getURL();
		attributes["Username"] = getUser();

		Secret.password_clearv.begin (pwSchema, attributes, null, (obj, async_res) => {
			try
			{
				removed = Secret.password_clearv.end(async_res);
			}
			catch(GLib.Error e)
			{
				Logger.error("freshUtils.deletePassword: %s".printf(e.message));
			}
		});
		return removed;
	}

	public string getHtaccessPasswd()
	{
		var pwSchema = new Secret.Schema ("org.gnome.feedreader.password", Secret.SchemaFlags.NONE,
		                                  "URL", Secret.SchemaAttributeType.STRING,
		                                  "Username", Secret.SchemaAttributeType.STRING,
										  "htaccess", Secret.SchemaAttributeType.BOOLEAN);

		var attributes = new GLib.HashTable<string,string>(str_hash, str_equal);
		attributes["URL"] = getURL();
		attributes["Username"] = getHtaccessUser();
		attributes["htaccess"] = "true";

		string passwd = "";

		try{
			passwd = Secret.password_lookupv_sync(pwSchema, attributes, null);
		}
		catch(GLib.Error e){
			Logger.error("freshUtils: getHtaccessPasswd: " + e.message);
		}

		if(passwd == null)
		{
			return "";
		}

		return passwd;
	}

	public void setHtAccessPassword(string passwd)
	{
		var pwAuthSchema = new Secret.Schema ("org.gnome.feedreader.password", Secret.SchemaFlags.NONE,
											  "URL", Secret.SchemaAttributeType.STRING,
											  "Username", Secret.SchemaAttributeType.STRING,
											  "htaccess", Secret.SchemaAttributeType.BOOLEAN);
		var authAttributes = new GLib.HashTable<string,string>(str_hash, str_equal);
		authAttributes["URL"] = getURL();
		authAttributes["Username"] = getHtaccessUser();
		authAttributes["htaccess"] = "true";
		try
		{
			Secret.password_storev_sync(pwAuthSchema,
										authAttributes,
										Secret.COLLECTION_DEFAULT,
										"FeedReader: freshRSS htaccess Authentication",
										passwd,
										null);
		}
		catch(GLib.Error e)
		{
			Logger.error("freshUtils: setHtAccessPassword: " + e.message);
		}
	}
}
