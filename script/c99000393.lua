--하이사이버네틱 네리하
local s,id=GetID()
function s.initial_effect(c)
	--order summon
	aux.AddOrderProcedure(c,"L",s.orderchk,aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),s.ordfil1)
	c:EnableReviveLimit()
	--이 카드를 오더 소환했을 때에 적용한다.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.regcon)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	--이 카드가 전투로 상대 몬스터를 파괴하고 묘지로 보냈을 때, 이하의 효과에서 1개를 선택하여 발동할 수 있다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCondition(aux.bdogcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.orderchk(g)
	return g:GetClassCount(Card.GetAttribute)==2
end
function s.ordfil1(c)
	return c:GetAttackAnnouncedCount()==0 and c:IsType(TYPE_MONSTER)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ORDER)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--이 턴에, 이 카드는 상대가 발동한 효과를 받지 않는다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(function(e,te) return te:IsActivated() and te:GetOwnerPlayer()~=e:GetHandlerPlayer() end)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	local atk=bc:GetTextAttack()
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
	local b2=atk>0
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))+1
	end
	Duel.SetTargetCard(bc)
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
	elseif op==1 then
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(atk)
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
	elseif op==2 then
		Duel.SetTargetPlayer(1-tp)
		Duel.SetTargetParam(atk)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
	end
	e:SetLabel(op)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	--그 몬스터를 자신 필드에 수비 표시로 특수 소환한다.
	if e:GetLabel()==0 then
		if tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	--그 몬스터의 원래 공격력만큼 자신의 LP를 회복한다.
	elseif e:GetLabel()==1 then
		if tc:IsRelateToEffect(e) then
			local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
			local dam=tc:GetTextAttack()
			if dam<0 then dam=0 end
			Duel.Recover(p,dam,REASON_EFFECT)
		end
	--그 몬스터의 원래 공격력만큼의 데미지를 상대에게 준다.
	elseif e:GetLabel()==2 then
		if tc:IsRelateToEffect(e) then
			local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
			local dam=tc:GetTextAttack()
			if dam<0 then dam=0 end
			Duel.Damage(p,dam,REASON_EFFECT)
		end
	end
end