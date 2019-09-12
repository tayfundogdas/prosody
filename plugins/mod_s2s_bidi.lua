-- Prosody IM
-- Copyright (C) 2019 Kim Alvefur
--
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--

local st = require "util.stanza";

local xmlns_bidi_feature = "urn:xmpp:features:bidi"
local xmlns_bidi = "urn:xmpp:bidi";

module:hook("s2s-stream-features", function(event)
	local origin, features = event.origin, event.features;
	if origin.type == "s2sin_unauthed" then
		features:tag("bidi", { xmlns = xmlns_bidi_feature }):up();
	end
end);

module:hook_tag("http://etherx.jabber.org/streams", "features", function (session, stanza)
	if session.type == "s2sout_unauthed" then
		local bidi = stanza:get_child("bidi", xmlns_bidi_feature);
		if bidi then
			session.incoming = true;
			session.log("debug", "Requesting bidirectional stream");
			session.sends2s(st.stanza("bidi", { xmlns = xmlns_bidi }));
		end
	end
end, 200);

module:hook_tag("urn:xmpp:bidi", "bidi", function(session)
	if session.type == "s2sin_unauthed" then
		session.log("debug", "Requested bidirectional stream");
		session.outgoing = true;
		return true;
	end
end);
