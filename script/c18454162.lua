--크리보디슈
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xa4),2)
	local e1=MakeEff(c,"I","M")
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCL(1,id)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FTo","M")
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_RELEASE)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"FC","M")
	e3:SetCode(EVENT_RELEASE)
	WriteEff(e3,3,"O")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"F","G")
	e4:SetCode(EFFECT_EXTRA_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTR(1,0)
	e4:SetValue(s.val4)
	e4:SetOperation(s.op4)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"SC")
	e5:SetCode(EVENT_BE_MATERIAL)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	WriteEff(e5,5,"NO")
	c:RegisterEffect(e5)
end
function s.tfil1(c)
	return c:IsSetCard(0xa4) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsReleasable())
end
function s.tfun1(g)
	local fc=g:GetFirst()
	local nc=g:GetNext()
	return ((fc:IsAbleToHand() and nc:IsReleasable()) or (nc:IsAbleToHand() and fc:IsReleasable()))
		and ((fc:IsAttribute(ATTRIBUTE_FIRE) and nc:IsAttribute(ATTRIBUTE_WATER))
			or (fc:IsAttribute(ATTRIBUTE_WIND) and nc:IsAttribute(ATTRIBUTE_EARTH))
			or (fc:IsAttribute(ATTRIBUTE_LIGHT) and nc:IsAttribute(ATTRIBUTE_DARK))
			or (fc:IsAttribute(ATTRIBUTE_WATER) and nc:IsAttribute(ATTRIBUTE_FIRE))
			or (fc:IsAttribute(ATTRIBUTE_EARTH) and nc:IsAttribute(ATTRIBUTE_WIND))
			or (fc:IsAttribute(ATTRIBUTE_DARK) and nc:IsAttribute(ATTRIBUTE_LIGHT)))
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GMGroup(s.tfil1,tp,"D",0,nil)
	if chk==0 then
		return g:CheckSubGroup(s.tfun1,2,2)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
	Duel.SOI(0,CATEGORY_RELEASE,nil,1,tp,"D")
end
function s.ofil1(c,sg)
	return c:IsAbleToHand() and sg:IsExists(Card.IsReleasable,1,c)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GMGroup(s.tfil1,tp,"D",0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:SelectSubGroup(tp,s.tfun1,false,2,2)
	if sg and #sg==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=sg:FilterSelect(tp,s.ofil1,1,1,nil,sg)
		if #tg>0 then
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tg)
			sg:Sub(tg)
			Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RELEASE)
		end
	end
end
function s.nfil2(c,g)
	return g:IsContains(c)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetLinkedGroup()
	return eg:IsExists(s.nfil2,1,c,g)
end
function s.tfil2(c)
	return c:IsReleasable() or c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsOnField() and s.tfil2(chkc)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil2,tp,"O","O",1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.STarget(tp,s.tfil2,tp,"O","O",1,1,nil)
	Duel.SOI(0,CATEGORY_RELEASE,g,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RELEASE)
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsAttackAbove,nil,1)
	local sum=g:GetSum(Card.GetAttack)
	if sum>0 then
		Duel.Recover(tp,sum,REASON_EFFECT)
	end
end
function s.op4(c,e,tp,sg,mg,lc,og,chk)
	return true
end
function s.val4(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not c:IsAbleToRemove() then
			return Group.CreateGroup()
		else
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK then
		end
	elseif chk==2 then
	end
end
function s.con5(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=MakeEff(c,"S")
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetD(id,0)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	local e2=MakeEff(c,"F","M")
	e2:SetCode(EFFECT_REVERSE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	e2:SetAbsoluteRange(ep,1,0)
	e2:SetValue(s.oval52)
	rc:RegisterEffect(e2,true)
end
function s.oval52(e,re,r,rp,rc)
	return bit.band(r,REASON_BATTLE)>0
end