UPDATE texts SET str16 = '"' || name || '"' where str16 IS '';
VACUUM;
