--청록 실♩타키온 하이퍼노바
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE+CATEGORY_SEARCH)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetCondition(s.con2)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
function s.tfil1(c)
	return c:IsSetCard(0xc08) and not c:IsCode(id) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil1,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.ofil11(c)
	return c:IsAbleToHand() and c:IsLevelBelow(4) and c:IsType(TYPE_EFFECT)
end
function s.ofil12(c)
	return c:IsAbleToGrave() and c:IsSetCard(0xc08)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tfil1,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		aux.ToHandOrElse(tc,tp)
		if tc:IsLocation(LOCATION_HAND|LOCATION_GRAVE) then
			local sg=Duel.GetMatchingGroup(s.ofil11,tp,LOCATION_DECK,0,nil)
			if #sg>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local gg=Duel.SelectMatchingCard(tp,s.ofil12,tp,LOCATION_HAND,0,0,1,nil)
				local gc=gg:GetFirst()
				if gc then
					Duel.BreakEffect()
					if Duel.SendtoGrave(gg,REASON_EFFECT)>0 and gc:IsLocation(LOCATION_GRAVE) then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
						local hg=sg:Select(tp,1,1,nil)
						local hc=hg:GetFirst()
						if hc and Duel.SendtoHand(hg,nil,REASON_EFFECT)>0 then
							Duel.ConfirmCards(1-tp,hg)
							local e1=Effect.CreateEffect(c)
							e1:SetType(EFFECT_TYPE_FIELD)
							e1:SetCode(EFFECT_CANNOT_ACTIVATE)
							e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
							e1:SetTargetRange(1,0)
							e1:SetValue(s.oval11)
							e1:SetLabel(hc:GetOriginalCodeRule())
							e1:SetReset(RESET_PHASE|PHASE_END)
							Duel.RegisterEffect(e1,tp)
						end
					end
				end
			end
		end
	end
end
function s.oval11(e,re,tp)
	local rc=re:GetHandler()
	local code=e:GetLabel()
	local code1,code2=rc:GetOriginalCodeRule()
	return re:IsMonsterEffect() and (code1==code or code2==code)
end
function s.nfil2(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0xc08) and c:IsType(TYPE_MONSTER)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return aux.exccon(e,tp,eg,ep,ev,re,r,rp) and eg:IsExists(s.nfil2,1,nil,tp)
end
function s.tfil2(c,e,tp)
	return c:IsSetCard(0xc08) and c:IsMonster() and (c:IsAbleToHand()
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tfil2(chkc,e,tp)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil2,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.tfil2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		aux.ToHandOrElse(tc,tp,function(c)
			return tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		end,
		function(c)
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,0))
	end
end