module Blog::BlogHelper
  def tag_or_category_posts_url(tag)
    if tag.is_category?
      categorized_blog_posts_url tag.name
    else
      tagged_blog_posts_url tag.name
    end
  end
end
