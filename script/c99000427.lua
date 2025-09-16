--그림자 속에서 피어나는 꽃처럼
local s,id=GetID()
function s.initial_effect(c)
	--이 카드명은 룰상 "페넘브라 토큰"으로도 취급한다.
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0a:SetCode(EFFECT_ADD_CODE)
	e0a:SetValue(99000417)
	c:RegisterEffect(e0a)
	--자신이나 상대의 덱에 카드가 앞면으로 존재할 경우, 이 카드는 세트한 턴에도 발동할 수 있다.
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_SINGLE)
	e0b:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0b:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0b:SetCondition(s.actcon)
	c:RegisterEffect(e0b)
	--자신의 패 / 필드의 몬스터를 융합 소재로서 릴리스하고, 어둠 속성의 융합 몬스터 1장을 융합 소환한다.
	local e1=Fusion.CreateSummonEff({handler=c,
							fusfilter=aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),
							matfilter=Card.IsReleasable,
							extrafil=s.fextra,
							extratg=s.extra_target,
							extraop=s.extra_operation})
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--이 카드는 일반 몬스터(야수전사족 / 빛 / 레벨 3 / 공 1900 / 수 0)가 되고, 몬스터 존에 특수 소환한다.
	local params={matfilter=Card.IsAbleToRemove,
				extrafil=s.fextra2,
				extraop=Fusion.BanishMaterial}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop(Fusion.SummonEffTG(params),Fusion.SummonEffOP(params)))
	c:RegisterEffect(e2)
end
s.listed_series={0xc11}
s.listed_names={99000417}
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_DECK,LOCATION_DECK,1,nil)
end
function s.exfilter(c,lsc,rsc)
	local lv=c:GetLevel()
	return lv>lsc and lv<rsc and c:IsReleasable()
end
function s.chkfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp)
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(s.chkfilter,nil,tp)<=1
end
function s.fextra(e,tp,mg)
	if Duel.GetFieldCard(tp,LOCATION_PZONE,0) and Duel.GetFieldCard(tp,LOCATION_PZONE,1) then
		local lsc=Duel.GetFieldCard(tp,LOCATION_PZONE,0):GetLeftScale()
		local rsc=Duel.GetFieldCard(tp,LOCATION_PZONE,1):GetRightScale()
		if lsc>rsc then lsc,rsc=rsc,lsc end
		local eg=Duel.GetMatchingGroup(s.exfilter,tp,0,LOCATION_MZONE,nil,lsc,rsc)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.checkmat(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard,1,nil,0xc11)
end
function s.fextra2(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil),s.checkmat
	end
	return nil
end
function s.extra_target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_ONFIELD)
end
function s.extra_operation(e,tc,tp,sg)
	Duel.Release(sg,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
	sg:Clear()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0xc11,TYPE_MONSTER|TYPE_NORMAL,1900,0,3,RACE_BEASTWARRIOR,ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(fusion_target,fusion_operation)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0xc11,TYPE_MONSTER|TYPE_NORMAL,1900,0,3,RACE_BEASTWARRIOR,ATTRIBUTE_LIGHT) then
			c:AddMonsterAttribute(TYPE_NORMAL|TYPE_TRAP)
			Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
			c:AddMonsterAttributeComplete()
		end
		Duel.SpecialSummonComplete()
		if fusion_target(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectEffectYesNo(tp,e:GetHandler()) then
			Duel.BreakEffect()
			fusion_operation(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end