--데아 텔루스 테네브레
local s,id=GetID()
function s.initial_effect(c)
	--delight summon
	aux.AddDelightProcedure(c,aux.FilterBoolFunction(Card.IsLocation,LOCATION_GRAVE),2,2,s.delchk)
	c:EnableReviveLimit()
	--이 카드가 딜라이트 소환에 의해 딜레이 중일 경우, 이하의 효과를 얻는다. 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.regcon)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	--다음 자신 배틀 페이즈를 2회 실행할 수 있다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e,tp) return e:GetHandler():IsSummonType(SUMMON_TYPE_DELIGHT) and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_BP_TWICE) end)
	e2:SetOperation(s.doublebattlephase)
	c:RegisterEffect(e2)
end
s.custom_type=CUSTOMTYPE_DELIGHT
function s.delchk(g)
	return g:IsExists(aux.FilterBoolFunction(Card.IsLevel,8),1,nil)
end
function s.tfil1(c)
	local te=c:IsHasEffect(EFFECT_DELAY_TURN)
	if not te then
		return false
	end
	local val=te:GetValue()
	return c:IsSummonType(SUMMON_TYPE_DELIGHT) and (val>0 or (val==0 and Duel.GetCurrentPhase()<=PHASE_STANDBY))
		and te:GetLabel()&ELABEL_IS_DELIGHT_SUMMONING~=0
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetControler()
	local sg=aux.DelayGroup[tp]:Filter(s.tfil1,nil)
	return sg:IsContains(c)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--상대는 다음 배틀 페이즈를 2회 실행한다.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BP_TWICE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	if Duel.IsTurnPlayer(1-tp) and Duel.IsBattlePhase() then
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(s.bpcon)
		e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_OPPO_TURN,1)
	end
	Duel.RegisterEffect(e1,tp)
	--공격 대상을 그 상대 몬스터에 옮기고 데미지 계산을 실행한다.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(2)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	Duel.RegisterEffect(e2,tp)
end
function s.bpcon(e)
	return Duel.GetTurnCount()~=e:GetLabel()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and s.regcon(e,tp,eg,ep,ev,re,r,rp)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,a) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local tc=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,a):GetFirst()
		Duel.HintSelection(tc)
		if Duel.GetControl(tc,tp,PHASE_BATTLE,2)~=0 then
			if a:CanAttack() and not a:IsImmuneToEffect(e) then
				Duel.ChangeAttackTarget(tc,true)
			end
		end
	end
end
function s.doublebattlephase(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_BP_TWICE) then return end
	local turn_ct=Duel.GetTurnCount()
	local ct=Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase() and 2 or 1
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_BP_TWICE)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetCondition(function() return ct==1 or Duel.GetTurnCount()~=turn_ct end)
	e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_SELF_TURN,ct)
	Duel.RegisterEffect(e1,tp)
end