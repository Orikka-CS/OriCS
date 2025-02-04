--에페르 오브 클락
local s,id=GetID()
function s.initial_effect(c)
	--Xyz summon
	Xyz.AddProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	--이 카드는 엑시즈 소환 및 이하의 방법으로만 특수 소환할 수 있다.
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.xyzlimit)
	c:RegisterEffect(e0)
	--자신 메인 페이즈 2 에, 엑스트라 몬스터 존의 자신의 빛 속성 몬스터 1장을 릴리스했을 경우에 엑스트라 덱에서 특수 소환할 수 있다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	--時の機械－タイム?マシ?ン
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	--그 몬스터를 파괴한다.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--덱에서 통상 소환 가능한 빛 속성 몬스터 1장을 패에 넣는다.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	--時の機械－タイム?マシ?ン
	aux.GlobalCheck(s,function()
		s.desgroup=Group.CreateGroup()
		s.desgroup:KeepAlive()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.desgroupregop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.hspfilter(c,tp,sc)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLocation(LOCATION_MZONE) and c:IsInExtraMZone(tp)
		and c:IsControler(tp) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.hspfilter,1,false,1,true,c,tp,nil,false,nil,tp,c)
		and Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,s.hspfilter,1,1,false,true,true,c,nil,nil,false,nil,tp,c)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
function s.desgroupregopfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_GRAVE)
end
function s.desgroupregop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.desgroupregopfilter,nil)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		if Duel.GetCurrentChain()==0 then s.desgroup:Clear() end
		s.desgroup:Merge(tg)
		s.desgroup:Remove(function(c) return not c:HasFlagEffect(id) end,nil)
		Duel.RaiseEvent(s.desgroup,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
function s.filter(c,e)
	return c:IsCanBeEffectTarget(e) and Duel.GetLocationCount(c:GetPreviousControler(),LOCATION_MZONE)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=s.desgroup:Filter(s.filter,nil,e)
	if chkc then return g:IsContains(chkc) and s.filter(chkc,e,tp) end
	if chk==0 then return #g>0 end
	local tg=nil
	if #g==1 then
		tg=g
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		tg=g:Select(tp,1,1,nil)
	end
	Duel.SetTargetCard(tg)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e)
		and Duel.MoveToField(tc,tc:GetPreviousControler(),tc:GetPreviousControler(),LOCATION_MZONE,tc:GetPreviousPosition(),true) then
		tc:SetStatus(STATUS_SPSUMMON_STEP,false)
		tc:SetStatus(STATUS_SPSUMMON_TURN,true)
		if not c:IsRelateToEffect(e) then return end
		local og=c:GetOverlayGroup()
		if not (#og>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4))) then return end
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=og:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,tp,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsAttributeExcept(ATTRIBUTE_LIGHT) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler():GetBattleTarget(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsRelateToBattle() then
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.thfilter(c)
	return c:IsSummonableCard() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end