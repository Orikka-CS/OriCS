--설폭의 요화루
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tar2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetValue(s.val4)
	e4:SetTarget(s.tar4)
	e4:SetOperation(s.op4)
	c:RegisterEffect(e4)
	local params={handler=c,fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0xfa7),matfilter=Fusion.InHandMat,
		extrafil=s.tg5,extratg=s.tar5}
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(Fusion.SummonEffTG(params))
	e5:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e5)
end
s.listed_names={0xfa7}
function s.nfil2(c)
	return c:IsType(TYPE_FUSION) and c:IsLevelAbove(2)
end
function s.con2(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.nfil2,tp,LOCATION_MZONE,0,1,nil)
end
function s.tar2(e,c)
	return c:IsLevel(1) or c:IsLevel(10)
end
function s.vfil4(c,tp)
	return c:IsSetCard(0xfa7) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
		and c:IsControler(tp) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
end
function s.val4(e,c)
	local tp=e:GetHandlerPlayer()
	return s.vfil4(c,tp)
end
function s.tfil4(c)
	return c:IsMonster() and c:IsReleasable()
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return eg:IsExists(s.vfil4,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.tfil4,tp,LOCATION_HAND,0,1,nil)
	end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local tg=Duel.SelectMatchingCard(tp,s.tfil4,tp,LOCATION_HAND,0,1,1,nil)
		local tc=tg:GetFirst()
		e:SetLabelObject(tc)
		return true
	end
	return false
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,1-tp,id)
	local tc=e:GetLabelObject()
	Duel.Release(tc,REASON_EFFECT+REASON_REPLACE)
end
function s.tg5(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end