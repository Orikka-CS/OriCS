--constants
EFFECT_LINK_MAT_RESTRICTION=73941492+TYPE_LINK
EFFECT_CUSTOM_MAT_RESTRICTION=73941492+TYPE_SPSUMMON

--EFFECT_LINK_MAT_RESTRICTION
local lap=Link.AddProcedure
Link.AddProcedure=function(c,f,min,max,specialchk,desc)
	local materialchk=function(g,lc,sumtype,tp)
		if #g<=1 then return true end
		local gc=g:GetFirst()
		while gc do
			if gc:IsHasEffect(EFFECT_LINK_MAT_RESTRICTION) then
				local eff={gc:GetCardEffect(EFFECT_LINK_MAT_RESTRICTION)}
				for _,e in ipairs(eff) do
					local fValue=e:GetValue()
					local fFilter=function(tc,te) return not fValue(te,tc) end
					if g:IsExists(fFilter,1,gc,e) then return false end
				end
			end
			gc=g:GetNext()
		end
		return true
	end
	if not specialchk then
		lap(c,f,min,max,materialchk,desc)
	else
		lap(c,f,min,max,aux.AND(specialchk,materialchk),desc)
	end
end
