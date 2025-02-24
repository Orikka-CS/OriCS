--[ The Throne of Destiny ]
local s,id=GetID()
function s.initial_effect(c)

	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)

	local e99=MakeEff(c,"FC","M")
	e99:SetCode(EVENT_ADJUST)
	WriteEff(e99,99,"NO")
	c:RegisterEffect(e99)
	
	local e1=MakeEff(c,"Qo","M")
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DRAW)
	e1:SetCL(1,id)
	e1:SetCode(EVENT_FREE_CHAIN)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)

end

function s.matfilter(c,lc,stype,tp)
	return c:IsSetCard(0x9d70,lc,stype,tp) and not c:IsType(TYPE_LINK,lc,stype,tp)
end

function s.con99(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(id)==0
end
function s.op99(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		Duel.Hint(HINT_CARD,0,id)
		local atk=YuL.Random(500,4000)
		Duel.Hint(HINT_NUMBER,tp,atk)
		Duel.Hint(HINT_NUMBER,1-tp,atk)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(atk)
	c:RegisterEffect(e1)
	
end

function s.tar1fil(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsSetCard(0x9d70)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tar1fil,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,s.tar1fil,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc and Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)~=0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		if Duel.ChangePosition(tc,POS_FACEUP_ATTACK)~=0 then
			local eset={tc:GetOwnEffects()}
			local ce=nil
			for _,te in ipairs(eset) do
				if te:GetCode()==EVENT_ADJUST then
					ce=te
					break
				end
			end
			local e1=ce:Clone()
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_CUSTOM+id)
			tc:RegisterEffect(e1)
			Duel.RaiseSingleEvent(tc,EVENT_CUSTOM+id,e,REASON_EFFECT,tp,tp,0)
			e1:Reset()
			if tc:IsLevelAbove(3) and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end
