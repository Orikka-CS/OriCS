--크리보헤미안
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"FTo","H")
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetCL(1,id)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_RELEASE)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"STo")
	e5:SetCode(EVENT_RELEASE)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetCL(1,{id,2})
	WriteEff(e5,5,"TO")
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e6)
	local e7=MakeEff(c,"F","G")
	e7:SetCode(EFFECT_EXTRA_MATERIAL)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetTR(1,0)
	e7:SetValue(s.val7)
	e7:SetOperation(s.op7)
	c:RegisterEffect(e7)
	local e8=MakeEff(c,"SC")
	e8:SetCode(EVENT_BE_MATERIAL)
	e8:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	WriteEff(e8,8,"NO")
	c:RegisterEffect(e8)
end
s.listed_names={20065322}
function s.nfil1(c,tp)
	return c:IsSetCard(0xa4) and c:IsFaceup() and c:IsControler(tp)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.nfil1,1,nil,tp)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SOI(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function s.tfil3(c,e)
	return c:IsSetCard(0xa4) and c:IsReleasableByEffect(e) and not c:IsCode(id)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil3,tp,"D",0,1,nil,e)
	end
	Duel.SOI(0,CATEGORY_RELEASE,nil,1,tp,"D")
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SMCard(tp,s.tfil3,tp,"D",0,1,1,nil,e)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RELEASE)
	end
end
function s.tfil5(c)
	return c:IsCode(20065322) and c:IsAbleToHand()
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil5,tp,"DG",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"DG")
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,aux.NecroValleyFilter(s.tfil5),tp,"DG",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.op7(c,e,tp,sg,mg,lc,og,chk)
	return true
end
function s.val7(chk,summon_type,e,...)
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
function s.con8(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
function s.op8(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=MakeEff(c,"S")
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetD(id,0)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	local e2=MakeEff(c,"FC","M")
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	e2:SetTarget(s.otar82)
	e2:SetValue(s.oval82)
	e2:SetOperation(s.oop82)
	rc:RegisterEffect(e2)
	local e3=MakeEff(c,"FC","M")
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetReset(RESET_EVENT|RESETS_STANDARD)
	e3:SetTarget(s.otar83)
	e3:SetValue(s.oval83)
	e3:SetOperation(s.oop83)
	rc:RegisterEffect(e3)
	if not rc:IsType(TYPE_EFFECT) then
		local e4=MakeEff(c,"S")
		e4:SetCode(EFFECT_ADD_TYPE)
		e4:SetValue(TYPE_EFFECT)
		e4:SetReset(RESET_EVENT|RESETS_STANDARD)
		rc:RegisterEffect(e4,true)
	end
end
function s.otfil821(c,tp)
	return c:IsControler(tp) and c:IsOnField() and c:IsReason(REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
function s.otfil822(c,bc)
	local be={c:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE)}
	for _,te in pairs(be) do
		local v=te:GetValue()
		if not v or v==1 or v(te,bc) then
			return false
		end
	end
	return not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
function s.otar82(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then
		local c=e:GetHandler()
		return s.otfil821(tc,tp) and c:GetFlagEffect(id)==0
	end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a and a~=tc and s.otfil822(a,tc) then
		e:SetLabelObject(a)
		a:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	if d and d~=tc and s.otfil822(d,tc) then
		e:SetLabelObject(d)
		d:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
function s.oval82(e,c)
	local tp=e:GetHandlerPlayer()
	return s.otfil821(c,tp)
end
function s.oop82(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
	Duel.Hint(HINT_CARD,1-tp,id)
	local bc=e:GetLabelObject()
	bc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(bc,REASON_BATTLE+REASON_REPLACE)
end
function s.otfil83(c,tp)
	return c:IsControler(tp) and c:IsOnField() and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.otar83(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return eg:IsExists(s.otar83,1,nil,tp) and re:IsActivated() and rp~=tp and c:GetFlagEffect(id)==0
	end
	local cc=Duel.GetCurrentChain()
	if Duel.IsChainDisablable(cc) then
		return true
	end
	return false
end
function s.oval83(e,c)
	local tp=e:GetHandlerPlayer()
	return s.otfil83(c,tp)
end
function s.oop83(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cc=Duel.GetCurrentChain()
	local rc=re:GetHandler()
	if Duel.NegateEffect(cc) and rc:IsRelateToEffect(re) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
		Duel.Destroy(rc,REASON_EFFECT)
		local e1=MakeEff(c,"F")
		e1:SetCode(EFFECT_KURIBOHEMIAN)
		e1:SetReset(RESET_CHAIN)
		e1:SetLabel(cc)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTR(0,1)
		Duel.RegisterEffect(e1,tp)
	end
end