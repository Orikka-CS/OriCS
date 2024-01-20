--FOX 4 / 오토기
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.pfil1,2,2)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.val0)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(1,1)
	e1:SetOperation(s.op1)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(s.con3)
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCondition(s.con4)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_TOHAND)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCountLimit(1,{id,2})
	e5:SetCondition(s.con5)
	e5:SetCost(s.cost5)
	e5:SetTarget(s.tar5)
	e5:SetOperation(s.op5)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_ATTACK_ANNOUNCE)
	e6:SetCondition(s.con6)
	c:RegisterEffect(e6)
	if not s.global_check then
		s.global_check=true
		s[0]={}
		s[1]={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(function()
			s[0]={}
			s[1]={}
		end)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.pfil1(c,lc,sumtype,tp)
	local code=c:GetCode()
	return ((c:IsSetCard(0xe76,lc,sumtype,tp) and not c:IsSummonCode(lc,sumtype,tp,id))
		or s.g1:IsContains(c))
		and not s[tp][code]
end
function s.val0(e,c)
	local tp=c:GetControler()
	local g=c:GetMaterial()
	for tc in aux.Next(g) do
		local code=tc:GetCode()
		s[tp][code]=true
		if tc:IsControler(1-tp) then
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
s.g1=nil
function s.op1(c,e,tp,sg,mg,lc,og,chk)
	if not s.g1 then
		return true
	end
	local g=s.g1
	return #(sg&g)<2
end
function s.vfil1(c)
	return c:IsFaceup() and c:IsDisabled()
end
function s.val1(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler()
			or Duel.GetFlagEffect(tp,id)~=0 then
			return Group.CreateGroup()
		else
			s.g1=Duel.GetMatchingGroup(s.vfil1,tp,0,LOCATION_MZONE,nil)
			s.g1:KeepAlive()
			return s.g1
		end
	elseif chk==2 then
		if s.g1 then
			s.g1:DeleteGroup()
		end
		s.g1=nil
	end
end
function s.tfil2(c,lg)
	return lg:IsContains(c)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and lg:IsContains(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tfil2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,lg)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local fid=e:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(0,LOCATION_ONFIELD)
		e1:SetLabelObject(tc)
		e1:SetLabel(fid)
		e1:SetTarget(s.otar21)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.otar21(e,c)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		return false
	end
	local cg=tc:GetColumnGroup()
	return cg:IsContains(c) and c~=tc
end
function s.nfil3(c)
	return c:IsFaceup() and c:IsSetCard(0xe76) and not c:IsCode(id)
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.nfil3,tp,LOCATION_MZONE,0,1,nil)
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.nfil3,tp,LOCATION_MZONE,0,1,nil)
end
function s.tfil3(c)
	return c:IsFaceup() and c:IsDisabled() and c:IsAbleToGrave()
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsOnField() and chkc:IsControler(1-tp) and s.tfil3(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil3,tp,0,LOCATION_ONFIELD,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.tfil3,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
function s.con5(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		return false
	end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or #g==0 then
		return false
	end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() and tc:IsSetCard(0xe76)
end
function s.con6(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsTurnPlayer(tp) then 
		return false
	end
	local tc=Duel.GetAttackTarget()
	e:SetLabelObject(tc)
	return tc and tc:IsFaceup() and tc:IsSetCard(0xe76)
end
function s.cfil51(c)
	return not c:IsCode(id) and c:IsFaceup()
end
function s.cfil52(c)
	return c:IsFaceup() and c:IsDisabled() and c:IsReleasable()
end
function s.cost5(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetReleaseGroup(tp)
	rg=rg:Filter(Card.IsFaceup,nil)
	local sg=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_SZONE,0,nil)
	rg:Merge(sg)
	rg=rg:Filter(s.cfil51,nil)
	if Duel.IsPlayerAffectedByEffect(tp,112603719) and c112603719 and c112603719[tp]
		and not c112603719[tp][id] then
		local ag=Duel.GetMatchingGroup(s.cfil52,tp,0,LOCATION_ONFIELD,nil)
		rg:Merge(ag)
	end
	if chk==0 then
		return #rg>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=rg:Select(tp,1,1,nil)
	local tc=g:GetFirst()
	if tc:IsSetCard(0xe76) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	Duel.Release(g,REASON_COST)
end
function s.tfil5(c)
	return c:IsSetCard(0xe76) and c:IsAbleToDeck() and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tfil5,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if chk==0 then
		return #g>0
	end
	if e:GetCode()==EVENT_CHAINING then
		Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	end
	if e:GetLabel()==1 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
	end
end
function s.ofil5(c)
	return c:IsSetCard(0xe76) and c:IsAbleToHand() and (c:IsFaceup() or not c:IsOnField())
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tfil5,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,4,aux.dncheck,1,tp,HINTMSG_TODECK,nil,nil,true)
	if #sg>0 and Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)>0 then
		local ct=#sg
		if #sg>=1 then
			if e:GetCode()==EVENT_CHAINING then
				Duel.NegateActivation(ev)
			else
				Duel.NegateAttack()
			end
		end
		if #sg>=2 then
			if e:GetCode()==EVENT_CHAINING then
				local rc=re:GetHandler()
				if rc:IsRelateToEffect(re) then
					Duel.Destroy(rc,REASON_EFFECT)
				end
			else
				local a=Duel.GetAttacker()
				if a:IsRelateToBattle() then
					Duel.Destroy(a,REASON_EFFECT)
				end
			end
		end
		if #sg>=3 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
		if #sg==4 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetTargetRange(LOCATION_MZONE,0)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetValue(500)
			e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xe76))
			Duel.RegisterEffect(e1,tp)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			Duel.RegisterEffect(e2,tp)
		end
		if e:GetLabel()==1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			local tg=Duel.SelectMatchingCard(tp,s.ofil5,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
			if #tg>0 then
				Duel.BreakEffect()
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tg)
			end
		end
	end
end