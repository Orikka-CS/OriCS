--왕립 폭발도서관
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")	
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DAMAGE)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FC","HS")
	e2:SetCode(EFFECT_RCOUNTER_REPLACE+COUNTER_SPELL)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	WriteEff(e2,2,"NO")
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.nfil1(c)
	return ((c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_SPELLCASTER))
		or (c:IsType(TYPE_TRAP) and not c:IsCode(id))) and c:IsFacecup()
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LSTN("HD"),0)==0
		and not Duel.IEMCard(s.nfil1,tp,"OGR",0,1,nil)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GMGroup(Card.IsType,tp,"G",0,nil,TYPE_SPELL)
	if chk==0 then
		return #g>0
	end
	Duel.SOI(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*200)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GMGroup(Card.IsType,tp,"G",0,nil,TYPE_SPELL)
	Duel.Damage(1-tp,#g*200,REASON_EFFECT)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r&REASON_COST~=0 and re:IsActivated() and ep==tp and ev==3 and c:IsAbleToDeck()
		and (c:IsLoc("H") or c:IsFacedown())
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
end