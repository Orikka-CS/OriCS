--아스피 온 "이지스"
local s,id=GetID()
function s.initial_effect(c)
	--module summon
	aux.AddModuleProcedure(c,aux.FilterBoolFunction(Card.IsModuleAttribute,ATTRIBUTE_LIGHT|ATTRIBUTE_DARK),nil,1,1,nil)
	c:EnableReviveLimit()
	--그 대상을 적절한 대상이 되는 앞면 표시의 이 카드에게 옮긴다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2,id)
	e1:SetCondition(s.tgcon)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--이 카드를 대상으로 하는 상대의 마법 / 함정 / 몬스터의 효과는 무효화된다.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--이 카드는 1턴에 1번만 전투로는 파괴되지 않으며,
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetValue(s.indct)
	c:RegisterEffect(e3)
	--그 전투로 발생하는 자신에게로의 전투 데미지는 0 이 된다.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e4:SetOperation(s.op)
	c:RegisterEffect(e4)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or #g~=1 then return false end
	local tc=g:GetFirst()
	local c=e:GetHandler()
	if tc==c or not tc:IsLocation(LOCATION_ONFIELD) then return false end
	return Duel.CheckChainTarget(ev,c)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local g=Group.CreateGroup()
		g:AddCard(c)
		Duel.ChangeTargetCard(ev,g)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if g and g:IsContains(e:GetHandler()) then 
		Duel.NegateEffect(ev)
	end
end
function s.indct(e,re,r)
	local c=e:GetHandler()
	if r & REASON_BATTLE ==0 then return 0 end
	c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	return 1
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler())
		and e:GetHandler():GetFlagEffect(id)==0 then
		Duel.ChangeBattleDamage(tp,0)
	end
end