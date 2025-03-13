--[ Aranea ]
local s,id=GetID()
function s.initial_effect(c)

	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x3d71),5,2)

	local e99=MakeEff(c,"FTf","M")
	e99:SetD(id,2)
	e99:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e99:SetCode(EVENT_PHASE+PHASE_END)
	e99:SetCL(1)
	e99:SetOperation(s.op99)
	c:RegisterEffect(e99)
	
	local e1=MakeEff(c,"STo","M")
	e1:SetD(id,0)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCL(1)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"Qo","M")
	e2:SetD(id,1)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCL(1,id)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	WriteEff(e2,2,"NCTO")
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	
end

function Card.IsAraneaFood(c,def)
	return c:GetAttack()<def or (c:GetDefense()<def and not c:IsType(TYPE_LINK))
end

function s.op99(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local lv=0
	if #g>0 then
		for tc in g:Iter() do
			lv=tc:GetLevel()
			if tc:IsType(TYPE_XYZ) then lv=tc:GetRank() end
			if not tc:IsType(TYPE_LINK) and lv>0 then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_DEFENSE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(100*lv)
				tc:RegisterEffect(e1)
			end
		end
	end
	local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g2>0 then
		for sc in g2:Iter() do
			lv=sc:GetLevel()
			if sc:IsType(TYPE_XYZ) then lv=sc:GetRank() end
			if not sc:IsType(TYPE_LINK) and lv>0 then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e2:SetValue(-200*lv)
				sc:RegisterEffect(e2)
				local e3=e2:Clone()
				e3:SetCode(EFFECT_UPDATE_DEFENSE)
				sc:RegisterEffect(e3)
			end
		end
	end
end

function s.tar1fil(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN,REASON_EFFECT)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.tar1fil(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tar1fil,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.tar1fil,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.cost2chk(c,def)
	return c:IsM() and c:IsOnField() and c:IsAraneaFood(def)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local def=c:GetDefense()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) or s.cost2chk(rc,def) end
	if not s.cost2chk(rc,def) or Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		c:RemoveOverlayCard(tp,1,1,REASON_COST)
	end
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
