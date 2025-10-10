--하이퍼 사이코미네리
local s,id=GetID()
function s.initial_effect(c)
	--order summon
	aux.AddOrderProcedure(c,"R",nil,aux.FilterBoolFunctionEx(Card.IsType,TYPE_TUNER),aux.NOT(aux.FilterBoolFunctionEx(Card.IsType,TYPE_TUNER)))
	c:EnableReviveLimit()
	--자신은 "하이퍼 사이코미네리"를 1턴에 1번밖에 특수 소환할 수 없다.
	c:SetSPSummonOnce(id)
	--자신이나 상대의 LP가 회복하는 수치는 0 이 된다.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(id)
	e0:SetRange(LOCATION_MZONE)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetCondition(function(e) return e:GetHandler():IsAttackPos() end)
	e0:SetTargetRange(1,1)
	c:RegisterEffect(e0)
	local rec=Duel.Recover
	Duel.Recover=function(tp,val,r)
		if Duel.IsPlayerAffectedByEffect(tp,id) then
			return 0
		else
			return rec(tp,val,r)
		end
	end
	--이 카드는 전투로는 파괴되지 않으며,
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--이 카드의 전투로 발생하는 전투 데미지는 서로가 받는다.
	local e2=e1:Clone()
	e2:SetCode(EFFECT_BOTH_BATTLE_DAMAGE)
	c:RegisterEffect(e2)
	--이 카드를 제외한다. 그 후, 받은 데미지의 수치만큼만 자신의 LP를 회복한다.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==tp and r&(REASON_BATTLE|REASON_EFFECT)>0 and ev>=2000 end)
	e3:SetTarget(s.rtg)
	e3:SetOperation(s.rop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
function s.rtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
		Duel.Recover(tp,ev,REASON_EFFECT)
	end
end