--sparkle.exe: Crack the code, just sing with me
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","S")
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetTR("O",0)
	e2:SetTarget(s.tar2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
end
function s.tfil3(c)
	return c:IsSetCard("sparkle.exe") and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and (c:IsSSetable() or c:IsAbleToGrave())
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.tfil3,tp,"D",0,1,nil) and Duel.GetLocCount(tp,"S")>0
	end
	Duel.SPOI(0,CATEGORY_TOGRAVE,nil,1,tp,"D")
	Duel.SOI(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil3,tp,"D",0,1,1,nil)
	local tc=g:GetFirst()
	local b1=tc:IsSSetable()
	local b2=tc:IsAbleToGrave()
	local res=false
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	if op==1 then
		res=Duel.SSet(tp,tc)>0
	elseif op==2 then
		res=Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLoc("G")
	end
	if res and Duel.GetLocCount(tp,"S")>0 and c:IsRelateToEffect(e) then
		Duel.MoveToField(tc,tp,tp,LSTN("S"),POS_FACEUP,true)
	end
end
function s.tar2(e,c)
	return c:IsSetCard("sparkle.exe") and not c:IsCode(id)
end
function s.val2(e,re)
	local tp=e:GetHandlerPlayer()
	local cc=Duel.GetCurrentChain()
	if cc<=1 then
		return false
	end
	local p0=Duel.GetChainInfo(cc-1,CHAININFO_TRIGGERING_PLAYER)
	local p1=Duel.GetChainInfo(cc,CHAININFO_TRIGGERING_PLAYER)
	local ce=Duel.GetChainInfo(cc,CHAININFO_TRIGGERING_EFFECT)
	return tp~=re:GetOwnerPlayer() and p0==tp and p1~=tp and ce==re
end