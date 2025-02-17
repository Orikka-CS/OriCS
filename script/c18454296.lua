--µµÆÄ¹Î Á¾°áÀÚ
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
end
function s.cfil1(c,e,tp)
	local ec=e:GetHandler()
	return c:IsSetCard("µµÆÄ¹Î") and c:IsAbleToGraveAsCost()
		and Duel.IETarget(aux.TRUE,tp,"O","O",1,Group.FromCards(c,ec))
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil1,tp,"HO",0,1,c,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil1,tp,"HO",0,1,1,c,e,tp)
	local tc=g:GetFirst()
	if tc:IsCode(id) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsOnField() and chkc~=c
	end
	if chk==0 then
		return Duel.IETarget(aux.TRUE,tp,"O","O",1,c)
	end
	local maxct=1
	if e:GetLabel()==1 then
		maxct=4
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.STarget(tp,aux.TRUE,tp,"O","O",1,maxct,c)
	Duel.SOI(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end