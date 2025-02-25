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

	local e2=MakeEff(c,"Qo","G")
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(function(_,tp) return Duel.IsTurnPlayer(1-tp) end)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
	
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

function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.SendtoDeck(c,nil,2,REASON_COST)
end
function s.tar2fil(c,e,tp)
	return c:IsSetCard(0x9d70) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.tar2fil,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.tar2fil,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
