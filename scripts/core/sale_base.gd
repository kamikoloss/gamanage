# ゲームのパッケージと販売を表現するクラス
class_name SaleBase
extends Object


enum PlatformType { Mobile, PC, Console }


# ID (何作目)
var id: int = 0
# ゲームの種別 (MaterialType)
var material_type: MaterialData.MaterialType
# 販売プラットフォーム
var platform: PlatformType
# ゲームのタイトル
var screen_name: String = ""
# ゲームの価格
# 0 の場合は広告収益
var price: int = 0
# 総売上本数
var total_saled_amount: int = 0
# 総売上金額
var total_saled_money: int = 0
