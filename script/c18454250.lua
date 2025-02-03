--荤炔 碍飞狼 功力
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","F")
	e2:SetCode(id)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTR(1,0)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"F","F")
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetTR("M",0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,"功力"))
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"I","F")
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
	e5:SetCL(1,id)
	WriteEff(e5,5,"TO")
	c:RegisterEffect(e5)
	if not s.global_check then
		s.global_check=true
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsSummonType(SUMMON_TYPE_NORMAL) and not tc:IsSummonType(SUMMON_TYPE_TRIBUTE) and tc:GetMaterialCount()==0 then
		tc:RegisterFlagEffect(id-10000,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end
function s.vfil3(c)
	return c:IsLevelAbove(5) and c:IsFaceup() and c:GetFlagEffect(id-10000)~=0
		and c:IsSummonType(SUMMON_TYPE_NORMAL) and not c:IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.val3(e)
	local tp=e:GetHandlerPlayer()
	return #Duel.GMGroup(s.vfil3,tp,"M",0,nil)*500
end
function s.tfil5(c,e)
	return not c:IsType(TYPE_FIELD) and c:IsSetCard("功力") and (c:IsAbleToRemove() or c:IsLoc("R")) and c:IsFaceup()
		and (not e or c:IsCanBeEffectTarget(e))
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return false
	end
	local g1=Duel.GMGroup(s.tfil5,tp,"G",0,nil,e)
	local g2=Duel.GMGroup(s.tfil5,tp,"R",0,nil,e)
	if chk==0 then
		return #g1>0 and #g2>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg1=g1:Select(tp,1,#g2,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg2=g2:Select(tp,#sg1,#sg1,nil)
	Duel.SOI(0,CATEGORY_REMOVE,sg1,#sg1,0,0)
	Duel.SOI(0,CATEGORY_RECOVER,nil,0,tp,#sg1*500)
	Duel.SetTargetCard(sg1:Merge(sg2))
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	local gg=g:Filter(Card.IsLoc,nil,"G")
	local rg=g:Filter(Card.IsLoc,nil,"R")
	local ct1=0
	local ct2=0
	if #gg>0 then
		ct1=Duel.Remove(gg,POS_FACEUP,REASON_EFFECT)
		if ct1>0 and #rg>0 then
			ct2=Duel.SendtoGrave(rg,REASON_EFFECT+REASON_RETURN)
		end
	end
	if ct1>0 then
		Duel.Recover(tp,ct1*500,REASON_EFFECT)
	end
	if ct2>0 then
		local e1=MakeEff(c,"F")
		e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTR(1,0)
		e1:SetValue(ct2+1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end