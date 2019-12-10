require "tasks/sample_data/logging"

class ProductFactory
  include Logging

  def create_samples(enterprises)
    log "Creating products:"
    products = []
    data = product_data(enterprises, 7000)

    params = data[0].merge(
      supplier_id: data[0][:supplier].id,
      primary_taxon_id: data[0][:taxons].first.id,
      variant_unit: "weight",
      variant_unit_scale: 1,
      unit_value: 1,
      shipping_category: DefaultShippingCategory.find_or_create,
      tax_category_id: find_or_create_tax_category.id
    )

    20.times do |num|
      params[:name] = "Garlic#{7000 + num}"

      products << create_product(params)
    end
    products
  end

  private

  def product_data(enterprises, num)
    vegetables = Spree::Taxon.find_by_name('Vegetables')
    fruit = Spree::Taxon.find_by_name('Fruit')
    meat = Spree::Taxon.find_by_name('Meat and Fish')
    producers = enterprises.select(&:is_primary_producer)
    distributors = enterprises.select(&:is_distributor)
    [
      {
        name: "Garlic#{num}",
        price: 20.00,
        supplier: producers[0],
        taxons: [vegetables],
        distributor: distributors[0]
      }
    ]
  end

  def create_product(params)
    log "- #{params[:name]}"
    product = Spree::Product.create_with(params).find_or_create_by_name!(params[:name])
    product.variants.first.update_attribute :on_demand, true
    product
  end

  def find_or_create_tax_category
    unless @tax_category.present?
      tax_category_name = "Tax Category"
      @tax_category = Spree::TaxCategory.find_by_name(tax_category_name)
      @tax_category ||= Spree::TaxCategory.create!(name: tax_category_name)
    end
    @tax_category
  end
end
