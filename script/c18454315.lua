--그녀가 꿈꾸던 세상
local s,id=GetID()
function s.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_SPSUMMON_COUNT)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","S")
	e2:SetCode(EFFECT_SPSUMMON_COUNT_LIMIT)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTR(1,1)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"FTf","S")
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCategory(CATEGORY_DESTROY)
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"S","S")
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(s.con4)
	c:RegisterEffect(e4)
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return ad and (a:IsSummonType(SUMMON_TYPE_SPECIAL) or d:IsSummonType(SUMMON_TYPE_SPECIAL))
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d):Filter(Card.IsSummnonType,nil,SUMMON_TYPE_SPECIAL)
	Duel.SOI(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d):Filter(Card.IsSummnonType,nil,SUMMON_TYPE_SPECIAL):Filter(Card.IsRelateToBattle,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.con4(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IEMCard(Card.IsFacedown,tp,"O","O",1,nil)
end